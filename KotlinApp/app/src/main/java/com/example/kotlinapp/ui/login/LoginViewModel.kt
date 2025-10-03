package com.example.kotlinapp.ui.login

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.kotlinapp.data.models.LoginResponse
import com.example.kotlinapp.data.models.UserResponse
import com.example.kotlinapp.data.repository.AuthRepository
import kotlinx.coroutines.launch

class LoginViewModel : ViewModel() {
    
    private val authRepository = AuthRepository()
    
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
            val result = authRepository.login(email, password)
            
            result.fold(
                onSuccess = { loginResponse ->
                    viewModelScope.launch {
                        val userResult = authRepository.getCurrentUser(loginResponse.accessToken)
                        userResult.fold(
                            onSuccess = { user ->
                                _loginState.value = LoginState.Success(
                                    message = "Login successful! Welcome ${user.name}",
                                    token = loginResponse.accessToken,
                                    user = user
                                )
                            },
                            onFailure = { _ ->
                                _loginState.value = LoginState.Success(
                                    message = "Login successful! Welcome $email",
                                    token = loginResponse.accessToken,
                                    user = null
                                )
                            }
                        )
                    }
                },
                onFailure = { exception ->
                    _loginState.value = LoginState.Error(exception.message ?: "Login failed")
                }
            )
            
            _isLoading.value = false
        }
    }
    
    fun clearState() {
        _loginState.value = null
    }
}

sealed class LoginState {
    data class Success(
        val message: String,
        val token: String,
        val user: UserResponse?
    ) : LoginState()
    data class Error(val message: String) : LoginState()
}
