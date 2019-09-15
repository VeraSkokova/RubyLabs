def string_permutation(array, n)
  if n == 1
    return array.select { |s| s == s }
  end
  string_permutation(array, n - 1).map { |prefix| array.reduce([]) { |strings, symbol| strings.push(prefix + symbol) } }
      .flatten
      .reject { |arr| arr[-1] == arr[-2] }
end

#puts string_permutation(%w(a b c), 3)