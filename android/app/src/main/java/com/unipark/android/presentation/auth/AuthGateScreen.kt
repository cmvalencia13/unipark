package com.unipark.android.presentation.auth

import android.app.Activity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Badge
import androidx.compose.material.icons.filled.Email
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.platform.LocalContext

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.unipark.android.core.ui.components.GlassPanel
import com.unipark.android.core.ui.components.ShineButton
import com.unipark.android.core.ui.components.entranceAnimation
import com.unipark.android.core.ui.theme.Background
import com.unipark.android.core.ui.theme.Error
import com.unipark.android.core.ui.theme.OnBackground
import com.unipark.android.core.ui.theme.OnSurfaceVariant
import com.unipark.android.core.ui.theme.OutlineVariant
import com.unipark.android.core.ui.theme.PrimaryFixedDim
import com.unipark.android.core.ui.theme.SurfaceContainer

@Composable
fun AuthGateScreen(
    onAuthenticated: (AppRole) -> Unit,
    viewModel: AuthViewModel = hiltViewModel(),
) {
    val authState by viewModel.authState.collectAsState()
    var email by remember { mutableStateOf("") }
    val context = LocalContext.current

    val authLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            viewModel.handleAuthResult(context, result.data)
        }
    }

    // Navigate when authenticated
    LaunchedEffect(authState) {
        val authenticated = authState as? AuthState.Authenticated
        if (authenticated != null) {
            onAuthenticated(authenticated.role)
        }
    }


    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Background),
        contentAlignment = Alignment.Center,
    ) {
        // Center card
        GlassPanel(
            modifier = Modifier
                .padding(horizontal = 20.dp)
                .fillMaxWidth()
                .entranceAnimation(delayIndex = 0),
            cornerRadius = 16.dp,
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                // University badge icon
                Icon(
                    imageVector = Icons.Default.Badge,
                    contentDescription = null,
                    modifier = Modifier.size(64.dp),
                    tint = PrimaryFixedDim,
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Title
                Text(
                    text = "UniPark",
                    style = MaterialTheme.typography.headlineLarge.copy(
                        fontWeight = FontWeight.Bold,
                    ),
                    color = OnBackground,
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = "University Parking Access",
                    style = MaterialTheme.typography.bodyMedium,
                    color = OnSurfaceVariant,
                )

                Spacer(modifier = Modifier.height(32.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    FilterChip(
                        selected = selectedRole == AppRole.DRIVER,
                        onClick = { selectedRole = AppRole.DRIVER },
                        label = { Text("Driver") },
                        modifier = Modifier.weight(1f),
                    )
                    FilterChip(
                        selected = selectedRole == AppRole.SECURITY_GUARD,
                        onClick = { selectedRole = AppRole.SECURITY_GUARD },
                        label = { Text("Guard") },
                        modifier = Modifier.weight(1f),
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Email field
                OutlinedTextField(
                    value = email,
                    onValueChange = { email = it },
                    label = { Text("University Email") },
                    placeholder = { Text("student@university.edu") },
                    leadingIcon = {
                        Icon(
                            imageVector = Icons.Default.Email,
                            contentDescription = null,
                            tint = PrimaryFixedDim,
                        )
                    },
                    modifier = Modifier.fillMaxWidth(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                    singleLine = true,
                    shape = RoundedCornerShape(12.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedTextColor = OnBackground,
                        unfocusedTextColor = OnBackground,
                        focusedBorderColor = PrimaryFixedDim,
                        unfocusedBorderColor = OutlineVariant,
                        focusedLabelColor = PrimaryFixedDim,
                        unfocusedLabelColor = OnSurfaceVariant,
                        cursorColor = PrimaryFixedDim,
                        focusedContainerColor = SurfaceContainer,
                        unfocusedContainerColor = SurfaceContainer,
                    ),
                )

                Spacer(modifier = Modifier.height(24.dp))

                // Sign in button
                ShineButton(
                    label = if (authState is AuthState.Loading) "Signing In..." else "Sign In with University ID",
                    onClick = {
                        if (email.lowercase().contains("mock")) {
                            viewModel.loginWithMocks()
                        } else {
                            try {
                                val intent = viewModel.getAuthIntent(context)
                                authLauncher.launch(intent)
                            } catch (e: Exception) {
                                viewModel.loginWithMocks()
                            }
                        }
                    },
                    icon = Icons.Default.Badge,
                    modifier = Modifier.fillMaxWidth(),
                    containerColor = PrimaryFixedDim.copy(alpha = 0.15f),
                    contentColor = PrimaryFixedDim,
                    borderColor = PrimaryFixedDim.copy(alpha = 0.3f),
                )


                // Error message
                if (authState is AuthState.Error) {
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = (authState as AuthState.Error).message,
                        style = MaterialTheme.typography.labelSmall,
                        color = Error,
                    )
                }
            }
        }
    }
}
