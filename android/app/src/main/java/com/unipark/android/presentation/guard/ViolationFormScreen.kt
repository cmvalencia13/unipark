package com.unipark.android.presentation.guard

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.PhotoCamera
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.unipark.android.presentation.UniParkCardRadius
import java.util.UUID

@Composable
fun ViolationFormScreen(
    vehicleId: UUID = UUID(0, 2),
    lotId: UUID = UUID(0, 1),
    viewModel: ViolationFormViewModel = hiltViewModel(),
) {
    val state by viewModel.state.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text("Infraccion", style = MaterialTheme.typography.headlineSmall)
        OutlinedTextField(
            value = state.plate,
            onValueChange = viewModel::setPlate,
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Placa") },
            singleLine = true,
        )
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            listOf("Lote A", "Lote B", "Lote C").forEach { lot ->
                FilterChip(
                    selected = state.selectedLotName == lot,
                    onClick = { viewModel.selectLot(lot) },
                    label = { Text(lot) },
                )
            }
        }
        OutlinedTextField(
            value = state.reason,
            onValueChange = viewModel::setReason,
            modifier = Modifier.fillMaxWidth(),
            minLines = 5,
            label = { Text("Motivo") },
        )
        OutlinedButton(onClick = { }, shape = RoundedCornerShape(UniParkCardRadius)) {
            Icon(Icons.Outlined.PhotoCamera, contentDescription = null)
            Text("Agregar foto")
        }
        Button(
            onClick = { viewModel.submit(vehicleId, lotId) },
            enabled = state.plate.isNotBlank() && state.reason.isNotBlank(),
            shape = RoundedCornerShape(UniParkCardRadius),
            modifier = Modifier.fillMaxWidth(),
        ) {
            Text("Enviar infraccion")
        }
        state.error?.let { Text(it, color = MaterialTheme.colorScheme.error) }
    }

    if (state.saved) {
        AlertDialog(
            onDismissRequest = viewModel::clearSuccess,
            confirmButton = {
                TextButton(onClick = viewModel::clearSuccess) {
                    Text("Listo")
                }
            },
            title = { Text("Infraccion enviada") },
            text = { Text("El reporte fue enviado al endpoint de violaciones.") },
        )
    }
}
