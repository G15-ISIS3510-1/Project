package com.example.kotlinapp.ui.places

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.databinding.FragmentVisitedPlacesBinding

class VisitedPlacesFragment : Fragment(R.layout.fragment_visited_places) {
    private var _binding: FragmentVisitedPlacesBinding? = null
    private val binding get() = _binding!!

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentVisitedPlacesBinding.bind(view)

        binding.btnBack.setOnClickListener { findNavController().popBackStack() }
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }
}
