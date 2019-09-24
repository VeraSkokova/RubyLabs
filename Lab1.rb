def string_permutation(array, n)
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

#array = ["a", "b", "c"]
#n = 3
#print string_permutation(array, n)