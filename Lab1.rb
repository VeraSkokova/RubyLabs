def string_permutation(array, n)
  def combine(array, suffixes, n)
    if n <= 0
      return []
    end
    if n == 1
      return array
    end
    suffixes.map {
        |suffix| array + [suffix]
    }
        .reject { |arr| arr[-1] == arr[-2] }
        .map { |prefix| combine(prefix, suffixes, n - 1) }

  end

  array.map { |elem| combine([elem], array, n) }.flatten(n - 1)
end

#array = ["a", ["b", "c"], "d"]
#n = 3
#print string_permutation(array, n)