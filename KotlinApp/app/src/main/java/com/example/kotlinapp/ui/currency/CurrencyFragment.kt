package com.example.kotlinapp.ui.currency

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.databinding.FragmentCurrencyBinding

class CurrencyFragment : Fragment(R.layout.fragment_currency) {

    private var _binding: FragmentCurrencyBinding? = null
    private val binding get() = _binding!!

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentCurrencyBinding.bind(view)

        // TODO: aquí puedes guardar la preferencia al tocar cada tarjeta
        binding.cardUSD.setOnClickListener { /* guardar USD */ }
        binding.cardEUR.setOnClickListener { /* guardar EUR */ }
        binding.cardGBP.setOnClickListener { /* guardar GBP */ }
        binding.cardCOP.setOnClickListener { /* guardar COP */ }

        binding.btnBack.setOnClickListener { findNavController().popBackStack() }
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }
}
