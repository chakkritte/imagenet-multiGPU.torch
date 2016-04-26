-- Imagenet classification with Torch7 demo
--
-- Will be using Network-in-Network trained in Torch-7 with batch normalization
-- more information on it here
-- 
require 'image'
require 'nn'

-- Rescales and normalizes the image
function preprocess(im, img_mean)
  -- rescale the image
  local im3 = image.scale(im,224,224,'bilinear')
  -- subtract imagenet mean and divide by std
  for i=1,3 do im3[i]:add(-img_mean.mean[i]):div(img_mean.std[i]) end
  return im3
end

print '==> Downloading image'
local image_url = 'http://upload.wikimedia.org/wikipedia/commons/e/e9/Goldfish3.jpg'
local image_name = paths.basename(image_url)
if not paths.filep(image_name) then os.execute('wget '..image_url)   end

print '==> Loading network'
local net = torch.load('packModel_2.got')
net.model:evaluate()
print(net)

print '==> Loading image and imagenet mean'
local im = image.load(image_name)

print '==> Preprocessing'
-- Our network has mean and std saved in net.transform
print('ImageNet ', net.transform)
local I = preprocess(im, net.transform):view(1,3,224,224):float()

print 'Propagate through the network, sort outputs in decreasing order and show 5 best classes'
local _,classes = net.model:forward(I):view(-1):float():sort(true)
for i=1,5 do
  print('predicted class '..tostring(i)..': ', net.label[classes[i] ])
end
