require 'thread'

class MultithreadingArray
  def initialize(array, threads_count)
    @array = array
    @threads_count = threads_count
  end

  def map
    queue = NaivePriorityQueue.new
    queue << get_chunks(@threads_count).each_with_index
                 .map { |chunk, i| Task.new(i).run_job { chunk.map { |k| yield(k) } } }
    results = Array.new
    (0...queue.size).each { results << queue.pop }
    results.flatten
  end

  def any?
    get_chunks(@threads_count).each_with_index
        .map { |chunk, i| Task.new(i).run_job { chunk.any? { |k| yield(k) } } }
        .reduce { |i, j| i | j }
  end

  def all?
    get_chunks(@threads_count).each_with_index
        .map { |chunk, i| Task.new(i).run_job { chunk.all? { |k| yield(k) } } }
        .reduce { |i, j| i & j }
  end

  def select
    queue = NaivePriorityQueue.new
    queue << get_chunks(@threads_count).each_with_index
                 .map { |chunk, i| Task.new(i).run_job { chunk.select { |k| yield(k) } } }
    results = Array.new
    (0...queue.size).each { results << queue.pop }
    results.flatten
  end

  private

  def get_chunks(chunks_count)
    chunk_size = (@array.length / chunks_count.to_f).ceil
    temp = Array.new
    (0...chunks_count).each { |i| temp.push(i) }
    temp.map { |i| @array[i * chunk_size...([chunk_size * (i + 1), @array.length].min)] }
  end
end

class Task
  include Comparable

  def initialize(number)
    @number = number
  end

  attr_accessor :value, :number

  def run_job(&job)
    @value = Thread.new { job.call }.value
  end

  def <=>(other)
    @number <=> other.number
  end
end

class NaivePriorityQueue
  def initialize
    @semaphore = Mutex.new
    @elements = []
  end

  def <<(element)
    @semaphore.synchronize { @elements << element }
  end

  def pop
    @semaphore.synchronize {
      last_element_index = @elements.size - 1
      @elements.sort!
      @elements.delete_at(last_element_index)
    }
  end

  def size
    @semaphore.synchronize { @elements.size }
  end
end


#thread = Thread.new {[1, 2, 3, 4].any? { |i| i % 2 == 0 }}
#print thread.value

#task = Task.new(0, [1, 2, 3, 4])
#value = task.run_job { [1, 5, 3, 8].any? { |i| i % 2 == 0 } }
#print value

#task = Task.new(0, [1, 2, 3, 4])
#job = Proc.new { [1, 2, 3, 4].any? { |i| i % 2 == 0 } }
#value = task.run_job { job.call }
#print value

m_array = MultithreadingArray.new([2, 3, 4, 5, 6], 2)
print m_array.map { |i| i * 2 }



