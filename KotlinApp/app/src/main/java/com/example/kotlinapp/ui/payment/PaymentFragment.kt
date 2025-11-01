package com.example.kotlinapp.ui.payment

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.databinding.FragmentPaymentBinding

class PaymentFragment : Fragment(R.layout.fragment_payment) {

    private var _binding: FragmentPaymentBinding? = null
    private val binding get() = _binding!!

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentPaymentBinding.bind(view)


        val versionName = try {
            requireContext().packageManager.getPackageInfo(requireContext().packageName, 0).versionName
        } catch (e: Exception) { "3686.1000" }
        binding.tvVersion.text = "v.$versionName"


        binding.btnCurrency.setOnClickListener {
            findNavController().navigate(R.id.action_payment_to_currency)
        }

        binding.btnPaymentAnalytics.setOnClickListener {
            findNavController().navigate(R.id.action_payment_to_analytics)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
