require File.expand_path '../../test_helper.rb', __FILE__

describe TestDiff::Storage do
  subject { TestDiff::Storage.new('tmp/test_diff_coverage') }

  before :each do
    subject.clear
  end

  describe 'set and get' do
    it 'can store and retrieve hello.rb' do
      subject.set('hello.rb', 'spec/spec_helper.rb' => '0,0')
      subject.get('hello.rb').must_equal('spec/spec_helper.rb' => '0,0')
    end

    it 'can set new value' do
      subject.set('hello.rb', 'spec/spec_helper.rb' => '0,0')
      subject.set('hello.rb', 'spec/test_helper.rb' => '0,0')
      subject.get('hello.rb').must_equal('spec/test_helper.rb' => '0,0')
    end

    it 'can override key in hello.rb' do
      subject.set('hello.rb', 'spec/spec_helper.rb' => '0,0')
      subject.set('hello.rb', 'spec/spec_helper.rb' => '1,1')
      subject.get('hello.rb').must_equal('spec/spec_helper.rb' => '1,1')
    end

    it 'can store and retrieve app/models/hello.rb' do
      subject.set('app/models/hello.rb', 'tests/test_helper.rb' => '0,0')
      subject.get('app/models/hello.rb').must_equal('tests/test_helper.rb' => '0,0')
    end

    it 'cannot store arrays' do
      -> { subject.set('app/models/hello.rb', ['tests/test_helper.rb', '0,0']) }.must_raise RuntimeError
    end

    it 'cannot store strings' do
      -> { subject.set('app/models/hello.rb', 'tests/test_helper.rb') }.must_raise RuntimeError
    end
  end

  describe 'find_for' do
    it 'returns empty array' do
      subject.find_for(['test.rb']).must_equal []
    end

    it 'ignores hello_spec.rb because only loaded' do
      subject.set('hello_spec.rb', 'test.rb' => '0,0,,,0')
      subject.find_for(['test.rb']).must_equal []
    end

    it 'returns hello_spec.rb' do
      subject.set('hello_spec.rb', 'test.rb' => '1,1')
      subject.find_for(['test.rb']).must_equal ['hello_spec.rb']
    end

    it 'returns hello_spec.rb and spec/tester_spec.rb' do
      subject.set('hello_spec.rb', 'test.rb' => '1,1')
      subject.set('spec/tester_spec.rb', 'test.rb' => '1,1')
      subject.find_for(['test.rb']).must_equal %w(hello_spec.rb spec/tester_spec.rb)
    end

    it 'returns only sub folder' do
      subject.set('spec_contiki/hello_spec.rb', 'test.rb' => '1,1')
      subject.set('spec/tester_spec.rb', 'test.rb' => '1,1')
      subject.find_for(['test.rb'],'spec').must_equal %w(spec/tester_spec.rb)
    end

    it 'wont return test/other_spec.rb' do
      subject.set('test/other_spec.rb', 'test.rb' => '1,1')
      subject.find_for(['app/file.rb']).must_equal []
    end
  end
end
