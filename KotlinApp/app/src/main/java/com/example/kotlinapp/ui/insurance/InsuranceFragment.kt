package com.example.kotlinapp.ui.insurance

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import com.example.kotlinapp.R
import com.example.kotlinapp.data.local.InsurancePreferenceStore
import com.example.kotlinapp.databinding.FragmentInsuranceBinding
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class InsuranceFragment : Fragment(R.layout.fragment_insurance) {

    private var _binding: FragmentInsuranceBinding? = null
    private val binding get() = _binding!!
    private lateinit var prefs: InsurancePreferenceStore

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentInsuranceBinding.bind(view)
        prefs = InsurancePreferenceStore(requireContext().applicationContext)

        // 1️⃣ Recuperar selección guardada
        viewLifecycleOwner.lifecycleScope.launch {
            val saved = withContext(Dispatchers.IO) { prefs.getSelected() }
            highlight(saved)
        }

        // 2️⃣ Configurar listeners de selección
        binding.cardBasic.setOnClickListener { selectInsurance("Basic Coverage", 15) }
        binding.cardStandard.setOnClickListener { selectInsurance("Standard Protection", 25) }
        binding.cardPremium.setOnClickListener { selectInsurance("Premium Full Insurance", 40) }

        // 3️⃣ Listener para recomendación
        binding.btnRecommend.setOnClickListener { recommendInsurance() }
    }

    /**
     * Guarda la selección en DataStore y aplica highlight
     */
    private fun selectInsurance(name: String, price: Int) {
        viewLifecycleOwner.lifecycleScope.launch {
            withContext(Dispatchers.IO) { prefs.setSelected(name) }
            withContext(Dispatchers.Main) {
                highlight(name)
                Toast.makeText(context, "Selected: $name ($$price/day)", Toast.LENGTH_SHORT).show()
            }
        }
    }

    /**
     * Aplica color de borde distinto al seguro seleccionado
     */
    private fun highlight(name: String?) {
        val defaultStroke = ContextCompat.getColor(requireContext(), com.google.android.material.R.color.m3_sys_color_light_outline)
        val selectedStroke = ContextCompat.getColor(requireContext(), com.google.android.material.R.color.m3_sys_color_light_primary)

        binding.cardBasic.strokeColor = if (name == "Basic Coverage") selectedStroke else defaultStroke
        binding.cardStandard.strokeColor = if (name == "Standard Protection") selectedStroke else defaultStroke
        binding.cardPremium.strokeColor = if (name == "Premium Full Insurance") selectedStroke else defaultStroke
    }

    /**
     * Lee el día del input, recomienda un seguro y lo guarda
     */
    private fun recommendInsurance() {
        val day = binding.etUsageDay.text.toString().trim().toIntOrNull()

        if (day == null || day !in 1..31) {
            Toast.makeText(context, "Enter a valid day (1–31)", Toast.LENGTH_SHORT).show()
            return
        }

        // Lógica simple: a más días, más cobertura recomendada
        val (recommendedName, price) = when {
            day <= 10 -> "Basic Coverage" to 15
            day in 11..20 -> "Standard Protection" to 25
            else -> "Premium Full Insurance" to 40
        }

        // Mostrar texto de recomendación
        binding.tvRecommendation.text = "Recommended: $recommendedName for $day day(s) of rental."

        // Guardar y aplicar highlight
        selectInsurance(recommendedName, price)
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }
}
