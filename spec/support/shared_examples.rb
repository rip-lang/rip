shared_examples 'debug methods' do
  context '.class_instance.to_s' do
    specify { expect(class_instance.to_s).to eq(class_to_s) }
  end

  context '#to_s' do
    specify { expect(instance.to_s).to eq(instance_to_s) }
  end
end
