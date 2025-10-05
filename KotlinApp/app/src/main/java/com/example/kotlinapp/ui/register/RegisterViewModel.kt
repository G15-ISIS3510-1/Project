package com.example.kotlinapp.ui.register

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.models.UserResponse
import com.example.kotlinapp.data.repository.AuthRepository
import kotlinx.coroutines.launch

class RegisterViewModel : ViewModel() {
    
    private val authRepository = AuthRepository()
    
    private val _registerState = MutableLiveData<RegisterState>()
    val registerState: LiveData<RegisterState> = _registerState
    
    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading
    
    fun register(name: String, email: String, password: String, confirmPassword: String, phone: String = "3001234567", role: String = "renter") {
        // Validaciones requeridas
        when {
            name.isEmpty() -> {
                _registerState.value = RegisterState.Error("Name is required")
                return
            }
            email.isEmpty() -> {
                _registerState.value = RegisterState.Error("Email is required")
                return
            }
            password.isEmpty() -> {
                _registerState.value = RegisterState.Error("Password is required")
                return
            }
            confirmPassword.isEmpty() -> {
                _registerState.value = RegisterState.Error("Please confirm your password")
                return
            }
            password != confirmPassword -> {
                _registerState.value = RegisterState.Error("Passwords do not match")
                return
            }
            password.length < 8 -> {
                _registerState.value = RegisterState.Error("Password must be at least 8 characters")
                return
            }
            phone.length < 10 || phone.length > 15 -> {
                _registerState.value = RegisterState.Error("Phone must be between 10 and 15 characters")
                return
            }
        }
        
        _isLoading.value = true
        
        viewModelScope.launch {
            val result = authRepository.register(name, email, password, phone, role)
            
            result.fold(
                onSuccess = { userResponse ->
                    _registerState.value = RegisterState.Success(
                        message = "Account created successfully! Welcome ${userResponse.name}",
                        user = userResponse
                    )
                },
                onFailure = { exception ->
                    _registerState.value = RegisterState.Error(exception.message ?: "Registration failed")
                }
            )
            
            _isLoading.value = false
        }
    }
    
    fun clearState() {
        _registerState.value = null
    }
}

sealed class RegisterState {
    data class Success(
        val message: String,
        val user: UserResponse
    ) : RegisterState()
    data class Error(val message: String) : RegisterState()
}
