def string_permutation(array, n)
  if n == 1
    return array.map { |elem| [elem] }
  end
  array.map { |elem| [elem] }
      .map {
          |prefix| array.reduce([]) {
            |permutations, symbol| permutations.push(prefix + [symbol])
        }
      }
      .flatten(1)
      .reject { |arr| arr[-1] == arr[-2] }
end

print string_permutation(["a", ["b", "c"], "d"], 3)