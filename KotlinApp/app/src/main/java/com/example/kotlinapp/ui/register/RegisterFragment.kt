package com.example.kotlinapp.ui.register

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.databinding.FragmentRegisterBinding
import com.google.android.material.textfield.TextInputLayout

class RegisterFragment : Fragment() {
    
    private var _binding: FragmentRegisterBinding? = null
    private val binding get() = _binding!!
    
    private val viewModel: RegisterViewModel by viewModels()
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentRegisterBinding.inflate(inflater, container, false)
        return binding.root
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupObservers()
        setupClickListeners()
    }
    
    private fun setupObservers() {
        viewModel.registerState.observe(viewLifecycleOwner) { state ->
            when (state) {
                is RegisterState.Success -> {
                    showSuccess(state.message)
                    // Navegar de vuelta al login
                    findNavController().popBackStack()
                }
                is RegisterState.Error -> {
                    showError(state.message)
                }
                null -> {
                    // Estado limpio
                }
            }
        }
        
        viewModel.isLoading.observe(viewLifecycleOwner) { isLoading ->
            binding.progressBar.visibility = if (isLoading) View.VISIBLE else View.GONE
            binding.registerButton.isEnabled = !isLoading
            binding.registerButton.text = if (isLoading) "Creating account..." else "Sign up"
        }
    }
    
    private fun setupClickListeners() {
        binding.registerButton.setOnClickListener {
            performRegister()
        }
        
        binding.signInText.setOnClickListener {
            // Navegar de vuelta al login
            findNavController().popBackStack()
        }
        
        binding.termsLink.setOnClickListener {
            // Navegar a términos y condiciones
            findNavController().navigate(R.id.action_register_to_terms)
        }
    }
    
    private fun performRegister() {
        val name = binding.nameEditText.text.toString().trim()
        val email = binding.emailEditText.text.toString().trim()
        val password = binding.passwordEditText.text.toString().trim()
        val confirmPassword = binding.confirmPasswordEditText.text.toString().trim()
        
        clearErrors()
        viewModel.register(name, email, password, confirmPassword)
    }
    
    private fun showSuccess(message: String) {
        Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
    }
    
    private fun showError(message: String) {
        Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
    }
    
    private fun clearErrors() {
        binding.nameInputLayout.error = null
        binding.emailInputLayout.error = null
        binding.passwordInputLayout.error = null
        binding.confirmPasswordInputLayout.error = null
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
