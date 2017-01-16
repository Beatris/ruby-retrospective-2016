RSpec.describe 'Version' do
  describe '#new' do
    it 'creates an instance from valid version string' do
      expect { Version.new('1.1.5') }.to_not raise_error
      expect(Version.new('0.2')).to be_instance_of(Version)
    end
    it 'creates an instance with no parameters' do
      expect { Version.new }.to_not raise_error
    end
    it 'creates an instance from empty string' do
      expect { Version.new('') }.to_not raise_error
    end
    it 'creates an instance from another Version instance' do
      expect { Version.new(Version.new('')) }.to_not raise_error
      expect { Version.new(Version.new('1')) }.to_not raise_error
      expect { Version.new(Version.new('2.0')) }.to_not raise_error
    end
    it 'raises error for invalid argument' do
      expect { Version.new('a.b.c') }.to raise_error(ArgumentError)
      expect { Version.new('baba') }.to raise_error(ArgumentError)
      expect { Version.new(true) }.to raise_error(ArgumentError)
      expect { Version.new([]) }.to raise_error(ArgumentError)
    end
    it 'raises error with proper message for invalid version string' do
      msg = "Invalid version string '.1'"
      expect { Version.new('.1') }.to raise_error(ArgumentError, msg)
      msg = "Invalid version string '0.1.2.'"
      expect { Version.new('0.1.2.') }.to raise_error(ArgumentError, msg)
      msg = "Invalid version string '2..1'"
      expect { Version.new('2..1') }.to raise_error(ArgumentError, msg)
    end
  end

  describe '#to_s' do
    it 'returns the version string' do
      expect(Version.new('1.1.5').to_s).to eql('1.1.5')
      expect(Version.new('0.1').to_s).to eql('0.1')
    end
    it 'does not show 0 components at the end' do
      expect(Version.new('1.1.0').to_s).to eql('1.1')
      expect(Version.new('1.0.0').to_s).to eql('1')
    end
  end

  describe '#>' do
    it 'checks if the first version is greater than the second one' do
      expect(Version.new('1.1.0') > Version.new('1')).to be true
      expect(Version.new('1.1.2') > Version.new('1.1.3')).to be false
      v1 = Version.new('1.3.1')
      v2 = v1
      expect(v1 > v2).to be false
    end
  end

  describe '#>=' do
    it 'checks if the first version is greater or equal than the second one' do
      expect(Version.new('1.0.1') >= Version.new('1')).to be true
      expect(Version.new('4.3.5') >= Version.new('5')).to be false
      v1 = Version.new('1.3.1')
      v2 = v1
      expect(v1 >= v2).to be true
    end
  end

  describe '#<' do
    it 'checks if the first version is less than the second one' do
      expect(Version.new('1.1.0') < Version.new('1')).to be false
      expect(Version.new('1.1.2') < Version.new('1.1.3')).to be true
      v1 = Version.new('1.3.1')
      expect(v1 < Version.new('1.3.1')).to be false
    end
  end

  describe '#<=' do
    it 'checks if the first version is less than or equal to the second one' do
      expect(Version.new('1.1.0') <= Version.new('1')).to be false
      expect(Version.new('1.1.2') <= Version.new('1.1.3')).to be true
      v1 = Version.new('1.3.1')
      expect(v1 <= Version.new('1.3.1')).to be true
    end
  end

  describe '#==' do
    it 'checks if the two versions are equal' do
      v1 = Version.new('5.3.1')
      expect(v1 == Version.new('5.3.1')).to be true
      expect(Version.new('1.1.0') == Version.new('1.1')).to be true
      expect(Version.new('1.1.2') == Version.new('1.1.3')).to be false
      expect(Version.new('0.1.2') == Version.new('0.2.1.0')).to be false
    end
  end

  describe '#<=>' do
    it 'returns if the first is less than, greater than or equals the second' do
      v1 = Version.new('5.3.1')
      expect(v1 <=> Version.new('5.3.1')).to be 0
      expect(Version.new('1.1.0') <=> Version.new('1.1')).to be 0
      expect(Version.new('1.1.2') <=> Version.new('1.1.3')).to be -1
      expect(Version.new('2') <=> Version.new('0.2.1')).to be 1
    end
  end

  describe '#components' do
    it 'returns the components of the version' do
      expect(Version.new('').components).to eq []
      expect(Version.new('1.1.2').components).to eq [1, 1, 2]
    end
    it 'ignores 0 components at the end' do
      expect(Version.new('3.2.1.0').components).to eq [3, 2, 1]
      expect(Version.new('3.0.0').components).to eq [3]
    end
    it 'handles optional argument for the number of components wanted' do
      expect(Version.new('3.2.1').components(N = 1)).to eq [3]
      expect(Version.new('0.1.2').components(3)).to eq [0, 1, 2]
      expect(Version.new('2').components(2)).to eq [2, 0]
    end
    it 'does not modify the version' do
      v1 = Version.new("2.0.3.0.0")
      v1.components << "baba"
      expect(v1.components).to eq [2, 0, 3]
    end
  end

  describe "Range" do
    describe '#new' do
      it 'creates an instance from valid Version objects' do
        expect { Version::Range.new(Version.new, Version.new) }
          .to_not raise_error
        expect { Version::Range.new(Version.new('1.1.5'), Version.new('1.3')) }
          .to_not raise_error
        expect { Version::Range.new(Version.new('3'), Version.new('1')) }
          .to_not raise_error
      end
      it 'creates an instance from valid version strings' do
        expect { Version::Range.new('0.1', '1.3.5') }.to_not raise_error
        expect { Version::Range.new('3.2.1', '1.2.3') }.to_not raise_error
      end
      it 'raises error for invalid version string' do
        expect { Version::Range.new('a.b.c', '1') }
          .to raise_error(ArgumentError)
        expect { Version::Range.new(Version.new('1.2.3'), 'baba') }
          .to raise_error(ArgumentError)
        expect { Version::Range.new(0, true) }.to raise_error(ArgumentError)
      end
      it 'raises error with proper message for invalid version string' do
        msg = "Invalid version string '.1'"
        expect { Version::Range.new('5.6.7', '.1') }
          .to raise_error(ArgumentError, msg)
      end
    end

    describe '#include?' do
      before(:each) do
        @from_1_to_3 = Version::Range.new('1', '3')
      end
      it 'checks if the given version is in the range' do
        expect(@from_1_to_3.include?('1.5')).to be true
        expect(@from_1_to_3.include?('1.5.0')).to be true
        expect(@from_1_to_3.include?(Version.new('2.5.6'))).to be true
        expect(@from_1_to_3.include?(Version.new('3.0'))).to be false
        expect(@from_1_to_3.include?('3')).to be false
        expect(@from_1_to_3.include?('1.0.0')).to be true
        expect(@from_1_to_3.include?('0.0')).to be false
        expect(@from_1_to_3.include?(Version.new)).to be false
      end
      it 'handles invalid version strings' do
        expect { @from_1_to_3.include? 'a.b.c' }.to raise_error(ArgumentError)
      end
    end

    describe '#to_a' do
      it 'generates all versions from the beginning to the end' do
        range = Version::Range.new('1.1.9', '1.2.2')
        expect(range.to_a).to eq(
          [Version.new('1.1.9'), Version.new('1.2.0'), Version.new('1.2.1')]
        )
      end
    end
  end
end
