describe "Application 'ikazen'" do
  #before do
  #  @app = UIApplication.sharedApplication
  #end
  #
  #it "has one window" do
  #  @app.windows.size.should == 1
  #end

  it 'can create an AGQuad 3D transform' do

    transform = Warp.new.squareFromQuad_x0(10, y0: 12, x1: 100, y1: 24, x2: 1, y2: 230, x3:100, y3:300);

    #quad = AGQuadMake(AGPointMake(10, 12), AGPointMake(100, 24), AGPointMake(1, 230), AGPointMake(100, 300))
    #quad.tl =
    #quad.tr =
    #quad.bl =
    #quad.br =

    #scale = 1.0
    #scaledQuad = AGQuadApplyCATransform3D(quad, CATransform3DMakeScale(scale, scale, 1.0))
    #transform = CATransform3DWithQuadFromBounds(scaledQuad, [[0.0,0.0],[240.0, 320.0]])

    transform.should != nil

  end

end
