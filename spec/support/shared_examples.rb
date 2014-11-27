shared_examples 'debug methods' do
  context '.type_instance.to_s' do
    specify { expect(type_instance.to_s).to eq(type_to_s) }
  end

  context '#to_s' do
    specify { expect(instance.to_s).to eq(instance_to_s) }
  end
end
