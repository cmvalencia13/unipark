package com.unipark.android.presentation.driver

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.CreditCard
import androidx.compose.material.icons.outlined.Payments
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.unipark.android.presentation.UniParkCardRadius
import com.unipark.android.presentation.UniParkFull
import com.unipark.android.presentation.UniParkSuccess

@Composable
fun WalletScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text("Wallet", style = MaterialTheme.typography.headlineSmall)
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    brush = Brush.linearGradient(
                        listOf(MaterialTheme.colorScheme.primary, Color(0xFF1976D2)),
                    ),
                    shape = RoundedCornerShape(UniParkCardRadius),
                )
                .padding(20.dp),
        ) {
            Text("$25.50", style = MaterialTheme.typography.displaySmall, fontWeight = FontWeight.Bold, color = Color.White)
            Text("Saldo disponible", color = Color.White.copy(alpha = 0.86f))
        }

        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
            listOf("$5", "$10", "$20", "$50").forEach { amount ->
                Button(
                    onClick = { },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp),
                ) {
                    Text("+$amount")
                }
            }
        }

        Text("Metodos de pago", style = MaterialTheme.typography.titleMedium)
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(UniParkCardRadius),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        ) {
            Row(
                modifier = Modifier.padding(16.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                Icon(Icons.Outlined.CreditCard, contentDescription = null)
                Column {
                    Text("Visa terminada en 4242", style = MaterialTheme.typography.titleMedium)
                    Text("Pago automatico activo")
                }
            }
        }
        OutlinedButton(onClick = { }, modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(UniParkCardRadius)) {
            Icon(Icons.Outlined.Payments, contentDescription = null)
            Text("Google Pay")
        }

        Text("Transacciones", style = MaterialTheme.typography.titleMedium)
        listOf(
            Transaction("Recarga wallet", "Hoy", "+$10.00", UniParkSuccess),
            Transaction("Permiso diario", "Ayer", "-$4.50", UniParkFull),
            Transaction("Recarga wallet", "20 mayo", "+$20.00", UniParkSuccess),
        ).forEach { tx ->
            Card(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(UniParkCardRadius)) {
                Row(
                    modifier = Modifier
                        .padding(16.dp)
                        .fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                ) {
                    Column {
                        Text(tx.description, style = MaterialTheme.typography.titleSmall)
                        Text(tx.date, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                    Text(tx.amount, color = tx.color, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

private data class Transaction(
    val description: String,
    val date: String,
    val amount: String,
    val color: Color,
)
