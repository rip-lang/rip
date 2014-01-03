shared_examples 'debug methods' do
  context '.class_instance.to_s' do
    specify { expect(class_instance.to_s).to eq(class_to_s) }
  end

  context '#to_s' do
    specify { expect(instance.to_s).to eq(instance_to_s) }
  end

  context '.class_instance.inspect' do
    specify { expect(class_instance.inspect).to eq(class_inspect) }
  end

  context '#inspect' do
    specify { expect(instance.inspect).to eq(instance_inspect) }
  end
end
