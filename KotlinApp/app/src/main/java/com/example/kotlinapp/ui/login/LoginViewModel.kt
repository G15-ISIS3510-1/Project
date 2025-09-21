package com.example.kotlinapp.ui.login

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class LoginViewModel : ViewModel() {
    
    private val _loginState = MutableLiveData<LoginState>()
    val loginState: LiveData<LoginState> = _loginState
    
    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading
    
    fun login(email: String, password: String) {
        if (email.isEmpty() || password.isEmpty()) {
            _loginState.value = LoginState.Error("Email and password are required")
            return
        }
        
        _isLoading.value = true
        
        viewModelScope.launch {
            try {
                // Simular llamada a API
                delay(2000)
                
                // Simulación de autenticación exitosa
                _loginState.value = LoginState.Success("Login successful! Welcome $email")
            } catch (e: Exception) {
                _loginState.value = LoginState.Error("Login failed: ${e.message}")
            } finally {
                _isLoading.value = false
            }
        }
    }
    
    fun clearState() {
        _loginState.value = null
    }
}

sealed class LoginState {
    data class Success(val message: String) : LoginState()
    data class Error(val message: String) : LoginState()
}
