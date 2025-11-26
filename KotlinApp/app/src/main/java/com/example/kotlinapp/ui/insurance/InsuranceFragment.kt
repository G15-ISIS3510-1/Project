package com.example.kotlinapp.ui.insurance

import android.os.Bundle
import android.view.View
import android.widget.Toast
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

        viewLifecycleOwner.lifecycleScope.launch {
            val saved = withContext(Dispatchers.IO) { prefs.getSelected() }
            highlight(saved)
        }

        binding.cardBasic.setOnClickListener { saveSelection("Basic Coverage", 15) }
        binding.cardStandard.setOnClickListener { saveSelection("Standard Protection", 25) }
        binding.cardPremium.setOnClickListener { saveSelection("Premium Full Insurance", 40) }

        binding.btnRecommend.setOnClickListener { recommendInsurance() }
    }

    private fun saveSelection(name: String, price: Int) {
        viewLifecycleOwner.lifecycleScope.launch {
            withContext(Dispatchers.IO) { prefs.setSelected(name) }
            withContext(Dispatchers.Main) {
                highlight(name)
                Toast.makeText(context, "Selected: $name ($$price/day)", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun highlight(name: String?) {
        val defaultStroke = resources.getColor(R.color.material_dynamic_neutral80, null)
        val selectedStroke = resources.getColor(R.color.material_dynamic_primary80, null)
        binding.cardBasic.strokeColor = if (name == "Basic Coverage") selectedStroke else defaultStroke
        binding.cardStandard.strokeColor = if (name == "Standard Protection") selectedStroke else defaultStroke
        binding.cardPremium.strokeColor = if (name == "Premium Full Insurance") selectedStroke else defaultStroke
    }

    private fun recommendInsurance() {
        val day = binding.etUsageDay.text.toString().toIntOrNull()
        if (day == null || day !in 1..31) {
            Toast.makeText(context, "Enter a valid day (1-31)", Toast.LENGTH_SHORT).show()
            return
        }

        val recommendation = when {
            day <= 10 -> "Basic Coverage"
            day in 11..20 -> "Standard Protection"
            else -> "Premium Full Insurance"
        }

        binding.tvRecommendation.text = "Recommended: $recommendation"
        saveSelection(recommendation, when (recommendation) {
            "Basic Coverage" -> 15
            "Standard Protection" -> 25
            else -> 40
        })
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }
}
