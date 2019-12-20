def string_permutation0(array, n)
  def combine(element, suffixes, n)
    if n <= 0
      return []
    end
    if n == 1
      return element
    end
    suffixes.reject { |suffix| element[-1] == suffix }
        .map {
            |suffix| element + [suffix]
        }
        .map { |prefix| combine(prefix, suffixes, n - 1) }
    # print "result=", result, "\n"
  end

  array.map { |elem| combine([elem], array, n) }.flatten(n - 1)
end

def string_permutations(array, n)
  def permutations(prefix, n, array)
    if n == 0
      return prefix
    end

    array.reject { |element| element == prefix[-1] }
        .reduce([]) { |result, element| result.push(permutations(prefix + [element], n - 1, array)) }
  end

  permutations([], n, array).flatten(n - 1)
end

array = ["a", "b", "c"]
n = 3
print string_permutations(array, n)