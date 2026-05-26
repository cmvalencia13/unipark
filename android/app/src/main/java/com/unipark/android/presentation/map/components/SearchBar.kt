package com.unipark.android.presentation.map.components

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Tune
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.unipark.android.core.ui.components.LiquidGlassPanel
import com.unipark.android.core.ui.theme.OnSurfaceVariant
import com.unipark.android.core.ui.theme.PrimaryFixedDim

@Composable
fun SearchBar(
    query: String,
    onQueryChange: (String) -> Unit,
    onTuneClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    LiquidGlassPanel(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp),
        cornerRadius = 16.dp,
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(
                imageVector = Icons.Default.Search,
                contentDescription = "Search",
                modifier = Modifier.size(20.dp),
                tint = OnSurfaceVariant,
            )
            Spacer(modifier = Modifier.width(12.dp))
            Text(
                text = "Find a lot...",
                style = MaterialTheme.typography.bodyMedium,
                color = OnSurfaceVariant.copy(alpha = 0.6f),
                modifier = Modifier.weight(1f),
            )
            IconButton(onClick = onTuneClick, modifier = Modifier.size(36.dp)) {
                Icon(
                    imageVector = Icons.Default.Tune,
                    contentDescription = "Filters",
                    modifier = Modifier.size(20.dp),
                    tint = PrimaryFixedDim,
                )
            }
        }
    }
}
