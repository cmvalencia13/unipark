package com.unipark.android.presentation.permits.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.unipark.android.core.ui.components.ShineButton
import com.unipark.android.core.ui.theme.OnSurfaceVariant
import com.unipark.android.core.ui.theme.PrimaryFixedDim
import com.unipark.android.core.ui.theme.SecondaryFixed
import com.unipark.android.core.ui.theme.SurfaceContainerHigh
import com.unipark.android.domain.model.PricingOption

@Composable
fun PricingCard(
    option: PricingOption,
    onPurchase: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val borderColor = if (option.highlight) SecondaryFixed.copy(alpha = 0.4f) else Color.White.copy(alpha = 0.06f)

    Column(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(SurfaceContainerHigh)
            .border(1.dp, borderColor, RoundedCornerShape(12.dp))
            .padding(16.dp),
    ) {
        if (option.highlight) {
            Text(
                text = "Recommended",
                style = MaterialTheme.typography.labelSmall,
                color = SecondaryFixed,
                modifier = Modifier
                    .clip(RoundedCornerShape(4.dp))
                    .background(SecondaryFixed.copy(alpha = 0.1f))
                    .padding(horizontal = 8.dp, vertical = 4.dp),
            )
            Spacer(modifier = Modifier.height(8.dp))
        }

        Text(
            text = option.name,
            style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.SemiBold),
            color = MaterialTheme.colorScheme.onBackground,
        )

        Spacer(modifier = Modifier.height(4.dp))

        Text(
            text = option.price,
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = PrimaryFixedDim,
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = option.description,
            style = MaterialTheme.typography.bodyMedium,
            color = OnSurfaceVariant,
        )

        Spacer(modifier = Modifier.height(16.dp))

        ShineButton(
            label = "Purchase",
            onClick = onPurchase,
            icon = Icons.Default.ShoppingCart,
            modifier = Modifier.fillMaxWidth(),
            containerColor = if (option.highlight) SecondaryFixed.copy(alpha = 0.15f) else Color.White.copy(alpha = 0.08f),
            contentColor = if (option.highlight) SecondaryFixed else PrimaryFixedDim,
            borderColor = if (option.highlight) SecondaryFixed.copy(alpha = 0.3f) else Color.White.copy(alpha = 0.1f),
        )
    }
}
