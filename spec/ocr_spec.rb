describe 'Text Recognition' do

  it 'recognizes total amount' do
    ocr = MotionOCR.new
    image_with_text = 'img.tiff'.uiimage.CGImage

    t = ocr.scan(image_with_text)

    puts t

    t.should include?('BRUUN')

  end
end