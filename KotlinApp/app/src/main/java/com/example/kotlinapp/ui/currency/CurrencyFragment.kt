package com.example.kotlinapp.ui.currency

import android.Manifest
import android.content.pm.PackageManager
import android.location.Geocoder
import android.location.Location
import android.os.Build
import android.os.Bundle
import android.telephony.TelephonyManager
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts.RequestPermission
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.data.local.CurrencyPreferenceStore
import com.example.kotlinapp.databinding.FragmentCurrencyBinding
import com.google.android.gms.location.LocationServices
import com.google.android.material.card.MaterialCardView
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.*
import java.util.Currency
import java.util.Locale
import kotlin.coroutines.resume
import kotlin.math.roundToInt

/**
 * Fragment responsible for suggesting which currency to use.
 * Strategy: CACHING STRATEGY (Persistent + Time-based cache)
 * - Uses DataStore via CurrencyPreferenceStore.
 * - Reuses last saved suggestion to avoid repeated lookups.
 * - Recalculates only if cache is older than 24h.
 */
class CurrencyFragment : Fragment(R.layout.fragment_currency) {

    private var _binding: FragmentCurrencyBinding? = null
    private val binding get() = _binding!!

    private val locationPermission = Manifest.permission.ACCESS_COARSE_LOCATION
    private lateinit var prefs: CurrencyPreferenceStore
    private var suggestionLoaded = false

    private val requestLocationPermission =
        registerForActivityResult(RequestPermission()) { granted ->
            viewLifecycleOwner.lifecycleScope.launch(Dispatchers.IO) {
                fetchAndShowSuggestion(useGeo = granted)
            }
        }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentCurrencyBinding.bind(view)
        prefs = CurrencyPreferenceStore(requireContext().applicationContext)

        // Load preferred currency and highlight
        viewLifecycleOwner.lifecycleScope.launch(Dispatchers.IO) {
            prefs.preferredOnce()?.let { withContext(Dispatchers.Main) { highlight(it) } }
        }

        // Manual selections
        binding.cardUSD.setOnClickListener { savePreferred("USD") }
        binding.cardEUR.setOnClickListener { savePreferred("EUR") }
        binding.cardGBP.setOnClickListener { savePreferred("GBP") }
        binding.cardCOP.setOnClickListener { savePreferred("COP") }

        binding.btnBack.setOnClickListener { findNavController().popBackStack() }

        if (!suggestionLoaded) {
            startSuggestion()
            suggestionLoaded = true
        }
    }

    private fun startSuggestion() {
        val hasPermission = ContextCompat.checkSelfPermission(
            requireContext(), locationPermission
        ) == PackageManager.PERMISSION_GRANTED

        viewLifecycleOwner.lifecycleScope.launch(Dispatchers.IO) {
            fetchAndShowSuggestion(useGeo = hasPermission)
        }

        if (!hasPermission) requestLocationPermission.launch(locationPermission)
    }

    /**
     * Fetch or reuse cached suggestion.
     * Implements persistent + time-based caching (24h validity).
     */
    private suspend fun fetchAndShowSuggestion(useGeo: Boolean) {
        // 1️⃣ Try cache
        val lastSuggested = prefs.getLastSuggested()
        val lastUpdated = prefs.getLastUpdated()
        val cacheValid = lastUpdated?.let {
            System.currentTimeMillis() - it < 24 * 60 * 60 * 1000
        } ?: false

        if (lastSuggested != null && cacheValid) {
            withContext(Dispatchers.Main) {
                binding.tvSuggestion.text = "Última sugerencia guardada: $lastSuggested (caché)"
                highlight(lastSuggested)
            }
            return
        }

        // 2️⃣ No valid cache → compute using strategies
        val strategies = buildList<CurrencySuggestionStrategy> {
            if (useGeo) add(GeoCurrencyStrategy)
            add(SimCardCurrencyStrategy)
            add(LocaleCurrencyStrategy)
        }

        val suggestion = CurrencySuggester.suggest(requireContext(), strategies)

        // Save suggestion in cache
        prefs.setLastSuggested(suggestion.currencyCode)

        // UI updates
        withContext(Dispatchers.Main) {
            binding.tvSuggestion.text = renderSuggestionText(suggestion)
            highlight(suggestion.currencyCode)
        }

        // Offer to update preferred currency
        val currentPreferred = prefs.preferredOnce()
        if (currentPreferred == null) {
            prefs.setPreferred(suggestion.currencyCode)
            showSnack("Se configuró ${suggestion.currencyCode} por ${suggestion.source}.") {
                viewLifecycleOwner.lifecycleScope.launch(Dispatchers.IO) {
                    prefs.clearPreferred()
                    withContext(Dispatchers.Main) { highlight("___NONE___") }
                }
            }
        }
    }

    private fun savePreferred(code: String) = viewLifecycleOwner.lifecycleScope.launch(Dispatchers.IO) {
        prefs.setPreferred(code)
        withContext(Dispatchers.Main) {
            highlight(code)
            showSnack("Moneda preferida: $code")
        }
    }

    private fun showSnack(message: String, undoAction: (() -> Unit)? = null) {
        Snackbar.make(binding.root, message, Snackbar.LENGTH_LONG).apply {
            undoAction?.let { setAction("Deshacer") { it() } }
        }.show()
    }

    private fun renderSuggestionText(s: CurrencySuggestion): String {
        val countryNameEs = Locale("es", s.countryCode).displayCountry.ifBlank { s.countryCode }
        val symbol = try { Currency.getInstance(s.currencyCode).getSymbol(Locale("es", s.countryCode)) }
                     catch (_: Exception) { s.currencyCode }
        return "Sugerencia: ${s.currencyCode} ($symbol) para $countryNameEs — fuente: ${s.source}."
    }

    private fun highlight(code: String) {
        val density = resources.displayMetrics.density
        val primaryColor = ContextCompat.getColor(requireContext(), com.google.android.material.R.color.material_dynamic_primary80)
        val neutralColor = ContextCompat.getColor(requireContext(), com.google.android.material.R.color.material_dynamic_neutral80)

        fun sel(card: MaterialCardView, selected: Boolean) {
            card.strokeColor = if (selected) primaryColor else neutralColor
            card.strokeWidth = ((if (selected) 3 else 1) * density).roundToInt()
        }

        sel(binding.cardUSD, code == "USD")
        sel(binding.cardEUR, code == "EUR")
        sel(binding.cardGBP, code == "GBP")
        sel(binding.cardCOP, code == "COP")
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }
}

/* ---------------------------- STRATEGY PATTERN ---------------------------- */

data class CurrencySuggestion(
    val currencyCode: String,
    val countryCode: String,
    val source: String
)

interface CurrencySuggestionStrategy {
    suspend fun getSuggestion(context: android.content.Context): CurrencySuggestion?
}

object CurrencySuggester {
    suspend fun suggest(
        context: android.content.Context,
        strategies: List<CurrencySuggestionStrategy>
    ): CurrencySuggestion = coroutineScope {
        val deferreds = strategies.map { async { it.getSuggestion(context) } }
        deferreds.firstNotNullOfOrNull { it.await() } ?: CurrencySuggestion("USD", "US", "Default")
    }
}

/* --- Strategies --- */

object GeoCurrencyStrategy : CurrencySuggestionStrategy {
    override suspend fun getSuggestion(context: android.content.Context): CurrencySuggestion? {
        val fused = LocationServices.getFusedLocationProviderClient(context)
        val loc = getLastLocationSuspend(fused) ?: return null

        val cc = withContext(Dispatchers.IO) {
            val geocoder = if (Build.VERSION.SDK_INT >= 33) Geocoder(context)
            else @Suppress("DEPRECATION") Geocoder(context, Locale.getDefault())
            geocoder.getFromLocation(loc.latitude, loc.longitude, 1)?.firstOrNull()?.countryCode
        } ?: return null

        val cur = countryToCurrency(cc) ?: return null
        return CurrencySuggestion(cur, cc, "Ubicación")
    }

    private suspend fun getLastLocationSuspend(
        client: com.google.android.gms.location.FusedLocationProviderClient
    ): Location? = suspendCancellableCoroutine { cont ->
        client.lastLocation
            .addOnSuccessListener { cont.resume(it) }
            .addOnFailureListener { cont.resume(null) }
    }
}

object SimCardCurrencyStrategy : CurrencySuggestionStrategy {
    override suspend fun getSuggestion(context: android.content.Context): CurrencySuggestion? {
        val tm = context.getSystemService(android.content.Context.TELEPHONY_SERVICE) as TelephonyManager
        val cc = tm.networkCountryIso?.uppercase(Locale.ROOT).orEmpty()
        if (cc.isBlank()) return null
        val cur = countryToCurrency(cc) ?: return null
        return CurrencySuggestion(cur, cc, "Red móvil")
    }
}

object LocaleCurrencyStrategy : CurrencySuggestionStrategy {
    override suspend fun getSuggestion(context: android.content.Context): CurrencySuggestion? {
        val cc = Locale.getDefault().country
        if (cc.isBlank()) return null
        val cur = countryToCurrency(cc) ?: return null
        return CurrencySuggestion(cur, cc, "Configuración del dispositivo")
    }
}

/* ---------------------------- Utilidades ---------------------------- */

private fun countryToCurrency(countryCode: String): String? = try {
    Currency.getInstance(Locale("", countryCode)).currencyCode
} catch (_: Exception) { null }
