"""
Test suite for the Calculator class.
These tests should ALL PASS in the initial clean state.
"""

import pytest
import sys
import os

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from calculator import Calculator


class TestCalculator:
    """Test basic calculator operations."""
    
    def setup_method(self):
        """Set up test fixtures."""
        self.calc = Calculator()
    
    def test_addition(self):
        """Test addition operation."""
        assert self.calc.add(2, 3) == 5
        assert self.calc.add(-1, 1) == 0
        assert self.calc.add(0, 0) == 0
    
    def test_subtraction(self):
        """Test subtraction operation."""
        assert self.calc.subtract(5, 3) == 2
        assert self.calc.subtract(0, 5) == -5
        assert self.calc.subtract(-3, -1) == -2
    
    def test_multiplication(self):
        """Test multiplication operation."""
        assert self.calc.multiply(4, 5) == 20
        assert self.calc.multiply(-2, 3) == -6
        assert self.calc.multiply(0, 100) == 0
    
    def test_division(self):
        """Test division operation."""
        assert self.calc.divide(10, 2) == 5
        assert self.calc.divide(7, 2) == 3.5
        assert self.calc.divide(-6, 3) == -2
    
    def test_division_by_zero(self):
        """Test division by zero raises error."""
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            self.calc.divide(5, 0)
    
    def test_power(self):
        """Test power operation."""
        assert self.calc.power(2, 3) == 8
        assert self.calc.power(5, 0) == 1
        assert self.calc.power(10, 2) == 100
    
    def test_square_root(self):
        """Test square root operation."""
        assert self.calc.square_root(9) == 3
        assert self.calc.square_root(16) == 4
        assert self.calc.square_root(0) == 0
    
    def test_square_root_negative(self):
        """Test square root of negative number raises error."""
        with pytest.raises(ValueError, match="Cannot calculate square root of negative number"):
            self.calc.square_root(-1)
    
    def test_percentage(self):
        """Test percentage calculation."""
        assert self.calc.percentage(100, 50) == 50
        assert self.calc.percentage(200, 25) == 50
        assert self.calc.percentage(80, 10) == 8
    
    def test_average(self):
        """Test average calculation."""
        assert self.calc.average([1, 2, 3, 4, 5]) == 3
        assert self.calc.average([10, 20]) == 15
        assert self.calc.average([100]) == 100
    
    def test_average_empty_list(self):
        """Test average of empty list raises error."""
        with pytest.raises(ValueError, match="Cannot calculate average of empty list"):
            self.calc.average([])


class TestEdgeCases:
    """Test edge cases and complex scenarios."""
    
    def setup_method(self):
        """Set up test fixtures."""
        self.calc = Calculator()
    
    def test_negative_scenarios(self):
        """Test operations with negative numbers."""
        assert self.calc.subtract(-5, -10) == 5
        assert self.calc.multiply(-3, -4) == 12
        assert self.calc.divide(-8, -2) == 4
    
    def test_decimal_operations(self):
        """Test operations with decimal numbers."""
        assert abs(self.calc.add(0.1, 0.2) - 0.3) < 1e-10
        assert abs(self.calc.multiply(0.5, 0.4) - 0.2) < 1e-10
    
    def test_large_numbers(self):
        """Test operations with large numbers."""
        assert self.calc.add(1000000, 2000000) == 3000000
        assert self.calc.multiply(1000, 1000) == 1000000
