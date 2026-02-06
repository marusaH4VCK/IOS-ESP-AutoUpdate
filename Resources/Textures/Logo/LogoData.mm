#import "LogoData.h"
#import <Metal/Metal.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

// Store original image dimensions
static float originalImageWidth = 0.0f;
static float originalImageHeight = 0.0f;

// Function to create MTLTexture from base64 string
id<MTLTexture> createTextureFromBase64Impl(NSString *base64String) {
    if (!base64String || base64String.length == 0) {
        return nil;
    }
    
    // Decode base64 to NSData
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    if (!imageData) {
        return nil;
    }
    
    // Create UIImage from NSData
    UIImage *image = [UIImage imageWithData:imageData];
    if (!image) {
        return nil;
    }
    
    // Get Metal device
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (!device) {
        return nil;
    }
    
    // Convert UIImage to MTLTexture
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    textureDescriptor.pixelFormat = MTLPixelFormatRGBA8Unorm;
    textureDescriptor.width = (NSUInteger)image.size.width;
    textureDescriptor.height = (NSUInteger)image.size.height;
    textureDescriptor.usage = MTLTextureUsageShaderRead;
    
    id<MTLTexture> texture = [device newTextureWithDescriptor:textureDescriptor];
    
    // Get CGImage from UIImage
    CGImageRef cgImage = image.CGImage;
    if (!cgImage) {
        return nil;
    }
    
    // Create bitmap context
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *bitmapData = malloc(width * height * 4);
    
    CGContextRef context = CGBitmapContextCreate(bitmapData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    if (!context) {
        free(bitmapData);
        return nil;
    }
    
    // Draw image to context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    
    // Copy data to MTLTexture
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [texture replaceRegion:region mipmapLevel:0 withBytes:bitmapData bytesPerRow:width * 4];
    
    // Cleanup
    CGContextRelease(context);
    free(bitmapData);
    
    return texture;
}

// Function to convert MTLTexture to UIImage for UIButton
UIImage* createUIImageFromMTLTexture(id<MTLTexture> texture) {
    if (!texture) {
        return nil;
    }
    
    // Get texture dimensions
    size_t width = texture.width;
    size_t height = texture.height;
    
    // Create bitmap context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *bitmapData = malloc(width * height * 4);
    
    CGContextRef context = CGBitmapContextCreate(bitmapData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    if (!context) {
        free(bitmapData);
        return nil;
    }
    
    // Get texture data
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [texture getBytes:bitmapData bytesPerRow:width * 4 fromRegion:region mipmapLevel:0];
    
    // Create CGImage from bitmap data
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
    
    // Cleanup
    CGImageRelease(cgImage);
    CGContextRelease(context);
    free(bitmapData);
    
    return image;
}

// Function to get logo texture
ImTextureID getLogoTexture() {
    static id<MTLTexture> logoTexture = nil;
    static bool tried = false;
    
    if (!tried) {
        tried = true;
        logoTexture = createTextureFromBase64Impl(kLogoBase64);
        
        if (logoTexture) {
            // Store original dimensions
            originalImageWidth = (float)logoTexture.width;
            originalImageHeight = (float)logoTexture.height;
        }
    }
    
    return (__bridge ImTextureID)logoTexture;
}

// Function to get logo image width
float getLogoImageWidth() {
    return originalImageWidth;
}

// Function to get logo image height
float getLogoImageHeight() {
    return originalImageHeight;
}


