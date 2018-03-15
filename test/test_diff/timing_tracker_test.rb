require File.expand_path '../../test_helper.rb', __FILE__

describe TestDiff::TimingTracker do
  let(:queue) { %w[1 2 3] }
  subject { TestDiff::TimingTracker.new(queue) }

  describe '#run' do
    it 'runs the tests that match test_pattern' do
      subject.run do
        sleep(0.5) while queue.pop
      end
    end
  end
end
