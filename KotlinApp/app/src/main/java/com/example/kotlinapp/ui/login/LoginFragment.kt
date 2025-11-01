package com.example.kotlinapp.ui.login

import android.Manifest
import android.os.Build
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import com.example.kotlinapp.R
import com.example.kotlinapp.core.work.LoginReminderWorker
import com.example.kotlinapp.databinding.FragmentLoginBinding
import com.google.android.material.snackbar.Snackbar
import com.google.android.material.textfield.TextInputLayout

class LoginFragment : Fragment() {

    private var _binding: FragmentLoginBinding? = null
    private val binding get() = _binding!!

    private val viewModel: LoginViewModel by viewModels()

    // Launcher para pedir permiso de notificaciones (Android 13+)
    private val notifPermissionLauncher =
        registerForActivityResult(
            ActivityResultContracts.RequestPermission()
        ) { /* puedes loguear el resultado si quieres */ }

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
                    state.user?.let {
                        showSuccess("¡Bienvenido ${it.name}! (${it.role})")
                    }

                    // 1) Pedir permiso de notificaciones en Android 13+
                    if (Build.VERSION.SDK_INT >= 33) {
                        notifPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                    }

                    // 2) Programar notificación para 60 minutos después del login
                    //    (para pruebas rápidas: usa delayMinutes = 1L)
                    LoginReminderWorker.schedule(
                        requireContext().applicationContext,
                        delayMinutes = 1L
                    )

                    // 3) Navegar como ya lo hacías
                    findNavController().navigate(R.id.messagesFragment)

                    // 4) Limpiar el estado para evitar re-disparos al rotar o volver
                    viewModel.clearState()
                }
                is LoginState.Error -> {
                    showError(state.message)
                }
                null -> { /* no-op */ }
            }
        }

        viewModel.isLoading.observe(viewLifecycleOwner) { isLoading ->
            binding.progressBar.visibility = if (isLoading) View.VISIBLE else View.GONE
            binding.loginButton.isEnabled = !isLoading
            binding.loginButton.text = if (isLoading) "Signing in..." else "Sign in"
        }
    }

    private fun setupClickListeners() {
        binding.loginButton.setOnClickListener { performLogin() }
        binding.signUpText.setOnClickListener {
            findNavController().navigate(R.id.action_login_to_register)
        }
    }

    private fun performLogin() {
        val email = binding.emailEditText.text.toString().trim()
        val password = binding.passwordEditText.text.toString().trim()
        clearErrors()

        when {
            email.isEmpty() -> {
                showFieldError(binding.emailInputLayout, "Email is required")
            }
            password.isEmpty() -> {
                showFieldError(binding.passwordInputLayout, "Password is required")
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
        // Puedes cambiar a Snackbar si prefieres
        Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
        // Snackbar.make(binding.root, message, Snackbar.LENGTH_LONG).show()
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
