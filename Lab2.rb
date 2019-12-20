require 'thread'

class MultithreadingArray
  def initialize(array, threads_count)
    @array = array
    @threads_count = threads_count
    @task_pool = TaskPool.new(threads_count, threads_count, array)
  end

  def map
    @task_pool.run do |chunk|
      chunk.map { |k| yield(k) }
    end
    @task_pool.finish
  end

  def any?
    @task_pool.run do |chunk|
      chunk.any? { |k| yield(k) }
    end
    @task_pool.finish.reduce { |i, j| i | j }
  end

  def all?
    @task_pool.run do |chunk|
      chunk.all? { |k| yield(k) }
    end
    @task_pool.finish.reduce { |i, j| i & j }
  end

  def select
    @task_pool.run do |chunk|
      chunk.select { |k| yield(k) }
    end
    @task_pool.finish
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

class PoolTask
  include Comparable

  def initialize(number, value)
    @number = number
    @value = value
  end

  attr_accessor :number, :value

  def <=>(other)
    @number <=> other.number
  end
end

class NaivePriorityQueue
  def initialize
    @elements = []
  end

  def <<(element)
    @elements << element
  end

  def pop
    last_element_index = @elements.size - 1
    @elements.sort!
    @elements.delete_at(0)
  end

  def size
    @elements.size
  end
end

class TaskPool
  def initialize(tasks_count, threads_count, array)
    @tasks_count = tasks_count
    @threads_count = threads_count
    @priority_queue = NaivePriorityQueue.new
    @array = array
  end

  def run
    queue = Queue.new
    get_chunks(@tasks_count, @array).each_with_index
        .map { |chunk, i| [i, chunk] }
        .each { |tuple| queue << tuple }
    (0..@threads_count).map do |i|
      Thread.new do
        res = []
        while not queue.empty?
          el = queue.pop
          index = el[0]
          chunk = el[1]
          temp = yield chunk
          pool_task = PoolTask.new(index, temp)
          res << pool_task
        end
        Thread.current["result"] = res
      end
    end.each { |t| t.join }.map { |t| t["result"] }
        .flatten
        .each { |local_result| @priority_queue << local_result }
    #.flatten(1).sort_by { |x| x[1] }.map { |el| el[0] }.flatten(1)
  end

  def finish
    results = Array.new
    (0...@priority_queue.size).each { results << @priority_queue.pop.value }
    results.flatten
  end

  def get_chunks(chunks_count, array)
    chunk_size = (array.length / chunks_count.to_f).ceil
    temp = Array.new
    (0...chunks_count).each { |i| temp.push(i) }
    temp.map { |i| array[i * chunk_size...([chunk_size * (i + 1), array.length].min)] }
  end
end

m_array = MultithreadingArray.new([2, 3, 4, 5, 6], 2)
print m_array.select { |i| i % 2 == 0 }
print "\n"
print m_array.all? { |i| i % 2 == 0 }
print "\n"
print m_array.any? { |i| i % 2 == 0 }
print "\n"
print m_array.map { |i| i * 2 }



