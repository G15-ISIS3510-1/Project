package com.example.kotlinapp.ui.login

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.databinding.FragmentLoginBinding
import com.google.android.material.textfield.TextInputLayout

class LoginFragment : Fragment() {
    
    private var _binding: FragmentLoginBinding? = null
    private val binding get() = _binding!!
    
    private val viewModel: LoginViewModel by viewModels()
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentLoginBinding.inflate(inflater, container, false)
        return binding.root
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupObservers()
        setupClickListeners()
    }
    
    private fun setupObservers() {
        viewModel.loginState.observe(viewLifecycleOwner) { state ->
            when (state) {
                is LoginState.Success -> {
                    showSuccess(state.message)
                    // Navegar a la siguiente pantalla
                    findNavController().navigate(R.id.action_login_to_home)
                }
                is LoginState.Error -> {
                    showError(state.message)
                }
                null -> {
                }
            }
        }
        
        viewModel.isLoading.observe(viewLifecycleOwner) { isLoading ->
            binding.progressBar.visibility = if (isLoading) View.VISIBLE else View.GONE
            binding.loginButton.isEnabled = !isLoading
            binding.loginButton.text = if (isLoading) "Signing in..." else "Sign in"
        }
    }
    
    private fun setupClickListeners() {
        binding.loginButton.setOnClickListener {
            performLogin()
        }
        
        binding.signUpText.setOnClickListener {
            Toast.makeText(context, "Navigate to Sign Up screen", Toast.LENGTH_SHORT).show()
        }
    }
    
    private fun performLogin() {
        val email = binding.emailEditText.text.toString().trim()
        val password = binding.passwordEditText.text.toString().trim()
        
        clearErrors()
        
        when {
            email.isEmpty() -> {
                showFieldError(binding.emailInputLayout, "Email is required")
                return
            }
            password.isEmpty() -> {
                showFieldError(binding.passwordInputLayout, "Password is required")
                return
            }
            else -> {
                viewModel.login(email, password)
            }
        }
    }
    
    private fun showSuccess(message: String) {
        Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
    }
    
    private fun showError(message: String) {
        Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
    }
    
    private fun showFieldError(inputLayout: TextInputLayout, message: String) {
        inputLayout.error = message
    }
    
    private fun clearErrors() {
        binding.emailInputLayout.error = null
        binding.passwordInputLayout.error = null
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
