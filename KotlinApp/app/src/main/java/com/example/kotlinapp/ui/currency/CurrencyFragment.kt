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
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import java.util.Currency
import java.util.Locale
import kotlin.coroutines.resume
import kotlin.math.roundToInt

/**
 * Fragmento responsable de sugerir la moneda a usar.
 *
 * Estrategia aplicada: CACHING STRATEGY (Persistent + Time-based cache)
 *  - Se usa DataStore (a través de CurrencyPreferenceStore)
 *  - Reutiliza la última sugerencia guardada para evitar consultas repetidas.
 *  - Solo recalcula si la caché no existe o tiene más de 24 horas.
 */
class CurrencyFragment : Fragment(R.layout.fragment_currency) {

    private var _binding: FragmentCurrencyBinding? = null
    private val binding get() = _binding!!

    private val locationPermission = Manifest.permission.ACCESS_COARSE_LOCATION
    private lateinit var prefs: CurrencyPreferenceStore

    private val requestLocationPermission =
        registerForActivityResult(RequestPermission()) { granted ->
            viewLifecycleOwner.lifecycleScope.launch {
                fetchAndShowSuggestion(useGeo = granted)
            }
        }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentCurrencyBinding.bind(view)
        prefs = CurrencyPreferenceStore(requireContext().applicationContext)

        // Cargar moneda preferida guardada y resaltarla
        viewLifecycleOwner.lifecycleScope.launch {
            prefs.preferredOnce()?.let { highlight(it) }
        }

        // Botones manuales
        binding.cardUSD.setOnClickListener { savePreferred("USD") }
        binding.cardEUR.setOnClickListener { savePreferred("EUR") }
        binding.cardGBP.setOnClickListener { savePreferred("GBP") }
        binding.cardCOP.setOnClickListener { savePreferred("COP") }

        binding.btnBack.setOnClickListener { findNavController().popBackStack() }

        startSuggestion()
    }

    private fun startSuggestion() {
        val hasPermission = ContextCompat.checkSelfPermission(
            requireContext(), locationPermission
        ) == PackageManager.PERMISSION_GRANTED

        viewLifecycleOwner.lifecycleScope.launch {
            fetchAndShowSuggestion(useGeo = hasPermission)
        }

        if (!hasPermission) requestLocationPermission.launch(locationPermission)
    }

    /**
     * Obtiene o reutiliza la moneda sugerida.
     * Implementa una estrategia de caché persistente y validación por tiempo (24 horas).
     */
    private suspend fun fetchAndShowSuggestion(useGeo: Boolean) {
        // 1️⃣ Intentar leer caché
        val lastSuggested = prefs.getLastSuggested()
        val lastUpdated = prefs.getLastUpdated()
        val cacheValid = lastUpdated?.let {
            System.currentTimeMillis() - it < 24 * 60 * 60 * 1000 // 24h
        } ?: false

        if (lastSuggested != null && cacheValid) {
            binding.tvSuggestion.text = "Última sugerencia guardada: $lastSuggested (caché)"
            highlight(lastSuggested)
            return
        }

        // 2️⃣ No hay caché válida → recalcular usando estrategias
        val strategies = buildList<CurrencySuggestionStrategy> {
            if (useGeo) add(GeoCurrencyStrategy)
            add(SimCardCurrencyStrategy)
            add(LocaleCurrencyStrategy)
        }

        val suggestion = CurrencySuggester.suggest(requireContext(), strategies)

        // Guardar en caché (última sugerencia)
        prefs.setLastSuggested(suggestion.currencyCode)

        // Mostrar en UI
        binding.tvSuggestion.text = renderSuggestionText(suggestion)
        highlight(suggestion.currencyCode)

        // Ofrecer actualizar moneda preferida
        val currentPreferred = prefs.preferredOnce()
        if (currentPreferred == null) {
            prefs.setPreferred(suggestion.currencyCode)
            Snackbar.make(
                binding.root,
                "Se configuró ${suggestion.currencyCode} por ${suggestion.source}.",
                Snackbar.LENGTH_LONG
            ).setAction("Deshacer") {
                viewLifecycleOwner.lifecycleScope.launch {
                    prefs.clearPreferred()
                    highlight("___NONE___")
                }
            }.show()
        }
    }

    private fun savePreferred(code: String) = viewLifecycleOwner.lifecycleScope.launch {
        prefs.setPreferred(code)
        highlight(code)
        Snackbar.make(binding.root, "Moneda preferida: $code", Snackbar.LENGTH_SHORT).show()
    }

    private fun renderSuggestionText(s: CurrencySuggestion): String {
        val countryNameEs = Locale("es", s.countryCode).displayCountry.ifBlank { s.countryCode }
        val symbol = try { Currency.getInstance(s.currencyCode).getSymbol(Locale("es", s.countryCode)) }
                     catch (_: Exception) { s.currencyCode }
        return "Sugerencia: ${s.currencyCode} ($symbol) para $countryNameEs — fuente: ${s.source}."
    }

    private fun highlight(code: String) {
        fun sel(card: MaterialCardView, selected: Boolean) {
            val density = resources.displayMetrics.density
            card.strokeColor = if (selected)
                ContextCompat.getColor(requireContext(), com.google.android.material.R.color.material_dynamic_primary80)
            else
                ContextCompat.getColor(requireContext(), com.google.android.material.R.color.material_dynamic_neutral80)
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
    ): CurrencySuggestion {
        for (s in strategies) {
            val r = s.getSuggestion(context)
            if (r != null) return r
        }
        return CurrencySuggestion("USD", "US", "Predeterminado")
    }
}

/* --- Estrategias para obtener sugerencia --- */

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
    override suspend fun getSuggestion(context: android.content.Context): CurrencySuggestion? = withContext(Dispatchers.Default) {
        val tm = context.getSystemService(android.content.Context.TELEPHONY_SERVICE) as TelephonyManager
        val cc = tm.networkCountryIso?.uppercase(Locale.ROOT).orEmpty()
        if (cc.isBlank()) return@withContext null
        val cur = countryToCurrency(cc) ?: return@withContext null
        CurrencySuggestion(cur, cc, "Red móvil")
    }
}

object LocaleCurrencyStrategy : CurrencySuggestionStrategy {
    override suspend fun getSuggestion(context: android.content.Context): CurrencySuggestion? = withContext(Dispatchers.Default) {
        val cc = Locale.getDefault().country
        if (cc.isBlank()) return@withContext null
        val cur = countryToCurrency(cc) ?: return@withContext null
        CurrencySuggestion(cur, cc, "Configuración del dispositivo")
    }
}

/* ---------------------------- Utilidades ---------------------------- */

private fun countryToCurrency(countryCode: String): String? = try {
    Currency.getInstance(Locale("", countryCode)).currencyCode
} catch (_: Exception) { null }
