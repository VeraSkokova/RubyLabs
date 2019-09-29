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
                 .map { |task| task.value }
    results = Array.new
    (0...queue.size).each { results << queue.pop }
    results.flatten
  end

  def any?
    get_chunks(@threads_count).each_with_index
        .map { |chunk, i| Task.new(i).run_job { chunk.any? { |k| yield(k) } } }
        .map { |task| task.value }
        .reduce { |i, j| i | j }
  end

  def all?
    get_chunks(@threads_count).each_with_index
        .map { |chunk, i| Task.new(i).run_job { chunk.all? { |k| yield(k) } } }
        .map { |task| task.value }
        .reduce { |i, j| i & j }
  end

  def select
    queue = NaivePriorityQueue.new
    queue << get_chunks(@threads_count).each_with_index
                 .map { |chunk, i| Task.new(i).run_job { chunk.select { |k| yield(k) } } }
                 .map { |task| task.value }
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

  attr_accessor :number

  def run_job(&job)
    @thread = Thread.new { job.call }
  end

  def value
    @thread.value
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

#m_array = MultithreadingArray.new([2, 3, 4, 5, 6], 2)
#print m_array.all? { |i| i % 2 == 0 }



