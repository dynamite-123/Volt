# Welford's Online Algorithm

## Overview

Welford's online algorithm is a numerically stable method for computing the variance of a dataset in a **single pass**, without requiring storage of all data values or multiple passes through the data. This algorithm is particularly useful when data is collected in a streaming fashion or when memory constraints are a concern.

For more details, see: [Algorithms for calculating variance - Wikipedia](https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance)

## Problem Statement

Computing variance using the naive formula can suffer from **catastrophic cancellation** errors:

$$\sigma^2 = \frac{\sum_{i=1}^{n} x_i^2}{n} - \left(\frac{\sum_{i=1}^{n} x_i}{n}\right)^2$$

When the sum of squares and the squared sum are very similar, subtracting them can lead to significant precision loss in floating-point arithmetic.

## Welford's Algorithm

Welford's algorithm computes the mean and variance efficiently using running sums instead of storing all data points.

### Key Variables

- **count (n)**: Number of samples seen so far
- **mean**: Running mean of the dataset
- **M2**: Sum of squares of differences from the current mean ($\sum_{i=1}^{n}(x_i - \bar{x}_n)^2$)

### Update Formulas

For each new value $x_n$:

$$\bar{x}_n = \bar{x}_{n-1} + \frac{x_n - \bar{x}_{n-1}}{n}$$

$$M_{2,n} = M_{2,n-1} + (x_n - \bar{x}_{n-1})(x_n - \bar{x}_n)$$

### Variance Calculation

Once all data has been processed:

- **Biased sample variance**: $\sigma_n^2 = \frac{M_2}{n}$
- **Unbiased sample variance** (with Bessel's correction): $s_n^2 = \frac{M_2}{n-1}$

## Python Implementation

```python
def update(existing_aggregate, new_value):
    """
    Update aggregate statistics with a new value.
    
    Args:
        existing_aggregate: Tuple of (count, mean, M2)
        new_value: New data point to add
    
    Returns:
        Updated tuple of (count, mean, M2)
    """
    (count, mean, M2) = existing_aggregate
    count += 1
    delta = new_value - mean
    mean += delta / count
    delta2 = new_value - mean
    M2 += delta * delta2
    return (count, mean, M2)


def finalize(existing_aggregate):
    """
    Calculate mean, variance and sample variance from aggregate.
    
    Args:
        existing_aggregate: Tuple of (count, mean, M2)
    
    Returns:
        Tuple of (mean, variance, sample_variance)
    """
    (count, mean, M2) = existing_aggregate
    if count < 2:
        return float("nan")
    else:
        variance = M2 / count
        sample_variance = M2 / (count - 1)
        return (mean, variance, sample_variance)


# Example usage
aggregate = (0, 0.0, 0.0)
data = [1, 2, 3, 4, 5]

for value in data:
    aggregate = update(aggregate, value)

mean, variance, sample_variance = finalize(aggregate)
print(f"Mean: {mean}")
print(f"Variance: {variance}")
print(f"Sample Variance: {sample_variance}")
```

## Advantages

1. **Single Pass**: Computes statistics while reading data sequentially, no need to store all values
2. **Numerically Stable**: Avoids catastrophic cancellation errors present in naive algorithms
3. **Memory Efficient**: Only requires storing three running statistics (count, mean, M2)
4. **Online Processing**: Ideal for streaming data or real-time applications
5. **Parallelizable**: Multiple sets of statistics can be merged efficiently

## Key Advantages Over Naive Algorithm

### Naive Algorithm (Unstable)
- Formula: $\sigma^2 = \frac{\sum x_i^2}{n} - \left(\frac{\sum x_i}{n}\right)^2$
- Problem: When values are large, the subtraction of two similar large numbers causes precision loss

### Welford's Algorithm (Stable)
- Uses incremental computation with normalized differences
- Computes differences from the current mean, keeping intermediate values small
- Avoids the subtraction of large similar numbers

### Example of Instability

Consider data: $(10^9 + 4, 10^9 + 7, 10^9 + 13, 10^9 + 16)$

- **Naive algorithm result**: -170.67 (WRONG!)
- **Welford's algorithm result**: 30 (CORRECT!)

## Extensions

### Weighted Variant
The algorithm can be extended to handle weighted data samples, replacing the simple counter $n$ with the sum of weights.

### Parallel Variant
Multiple subsets of data can be processed independently using Welford's algorithm, then combined using Chan's parallel formula:

$$M_{2,AB} = M_{2,A} + M_{2,B} + \delta^2 \cdot \frac{n_A \cdot n_B}{n_A + n_B}$$

### Higher-Order Moments
The algorithm can be generalized to compute skewness and kurtosis using similar incremental formulas.

## Applications

- Real-time analytics and streaming data processing
- Financial data analysis (computing rolling variance)
- Signal processing and sensor data collection
- Machine learning model training (online learning)
- Statistical monitoring and anomaly detection

## References

1. Welford, B. P. (1962). "Note on a method for calculating corrected sums of squares and products". Technometrics, 4(3), 419–420.
2. Knuth, D. E. (1998). The Art of Computer Programming, Volume 2: Seminumerical Algorithms.
3. Chan, T. F., Golub, G. H., & LeVeque, R. J. (1983). "Algorithms for computing the sample variance: Analysis and recommendations".
