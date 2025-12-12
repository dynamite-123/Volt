"""
Configuration for insight generation.

Centralizes all magic numbers and business rules for maintainability.
"""
from pydantic import BaseModel, Field, ConfigDict


class InsightThresholds(BaseModel):
    """Business rule thresholds for insight generation."""
    
    # Confidence assessment
    confidence_high_threshold: float = Field(
        default=0.9,
        ge=0,
        le=1,
        description="Threshold for 'high' confidence (90%+)"
    )
    confidence_moderate_threshold: float = Field(
        default=0.7,
        ge=0,
        le=1,
        description="Threshold for 'moderate' confidence (70%+)"
    )
    
    # Income volatility (coefficient of variation)
    volatility_high_threshold: float = Field(
        default=0.4,
        ge=0,
        description="High volatility threshold (40%+)"
    )
    volatility_moderate_threshold: float = Field(
        default=0.3,
        ge=0,
        description="Moderate volatility threshold (30%+)"
    )
    
    # Spending elasticity/flexibility
    elasticity_high_flexibility: float = Field(
        default=0.6,
        ge=0,
        le=1,
        description="High flexibility threshold (60%+ elasticity)"
    )
    elasticity_low_flexibility: float = Field(
        default=0.2,
        ge=0,
        le=1,
        description="Low flexibility threshold (20%- elasticity)"
    )
    
    # Impulse spending
    impulse_high_threshold: float = Field(
        default=0.7,
        ge=0,
        le=1,
        description="High impulse score threshold (70%+)"
    )
    impulse_moderate_threshold: float = Field(
        default=0.3,
        ge=0,
        le=1,
        description="Moderate impulse score threshold (30%+)"
    )
    
    # Quick wins
    quick_win_min_spending: float = Field(
        default=50.0,
        ge=0,
        description="Minimum monthly spending to consider for quick wins"
    )
    quick_win_reduction_percent: float = Field(
        default=0.15,
        ge=0,
        le=1,
        description="Conservative reduction percentage for potential savings (15%)"
    )
    quick_win_max_results: int = Field(
        default=5,
        ge=1,
        le=10,
        description="Maximum number of quick wins to return"
    )
    
    # Emergency fund recommendations
    emergency_fund_months_high_volatility: int = Field(
        default=6,
        ge=1,
        description="Months of coverage for high income volatility"
    )
    emergency_fund_months_moderate_volatility: int = Field(
        default=3,
        ge=1,
        description="Months of coverage for moderate income volatility"
    )
    emergency_fund_months_stable: int = Field(
        default=3,
        ge=1,
        description="Months of coverage for stable income"
    )
    
    # Data quality
    min_transactions_for_high_confidence: int = Field(
        default=50,
        ge=1,
        description="Minimum transactions for 'high' confidence in data"
    )
    min_transactions_for_building_confidence: int = Field(
        default=30,
        ge=1,
        description="Minimum transactions for 'building' confidence"
    )
    
    # Difficulty scoring (0-100 scale)
    difficulty_easy_max: int = Field(
        default=30,
        ge=0,
        le=100,
        description="Maximum score for 'easy' difficulty (0-30)"
    )
    difficulty_moderate_max: int = Field(
        default=60,
        ge=0,
        le=100,
        description="Maximum score for 'moderate' difficulty (31-60)"
    )
    # Above 60 = 'challenging'
    
    # Reliability scoring
    reliability_established_threshold: float = Field(
        default=0.7,
        ge=0,
        le=1,
        description="Threshold for 'established' category (70%+ reliability)"
    )
    
    # Income diversification and planning
    min_income_sources_for_stability: int = Field(
        default=3,
        ge=1,
        description="Minimum number of monthly income sources for stability"
    )
    
    good_month_income_multiplier: float = Field(
        default=1.2,
        ge=1.0,
        description="Multiplier to define 'good' income month (20% above average)"
    )
    
    lean_month_income_multiplier: float = Field(
        default=0.8,
        ge=0.0,
        le=1.0,
        description="Multiplier to define 'lean' income month (20% below average)"
    )
    
    flexible_spending_reduction_percent: float = Field(
        default=0.3,
        ge=0.0,
        le=1.0,
        description="Recommended spending reduction during lean months (30%)"
    )
    
    surplus_savings_multiplier: float = Field(
        default=0.8,
        ge=0.0,
        le=1.0,
        description="Percentage of surplus income to save during good months (80%)"
    )
    
    model_config = ConfigDict(frozen=True)  # Immutable configuration


class TimelineConfig(BaseModel):
    """Timeline estimation configuration."""
    
    high_confidence_timeline: str = Field(
        default="Achievable within 2-3 weeks",
        min_length=1,
        description="Timeline message for high confidence scenarios"
    )
    moderate_confidence_timeline: str = Field(
        default="Achievable within 1-2 months",
        min_length=1,
        description="Timeline message for moderate confidence scenarios"
    )
    low_confidence_timeline: str = Field(
        default="Requires 3+ months of habit adjustment",
        min_length=1,
        description="Timeline message for low confidence scenarios"
    )
    
    model_config = ConfigDict(frozen=True)


class InsightConfig(BaseModel):
    """Complete insight configuration bundle."""
    
    thresholds: InsightThresholds = Field(default_factory=InsightThresholds)
    timelines: TimelineConfig = Field(default_factory=TimelineConfig)
    
    model_config = ConfigDict(frozen=True)
