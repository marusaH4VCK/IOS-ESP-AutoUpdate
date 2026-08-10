#import "Esp/ImGuiDrawView.h"
#import "Init/IL2CPPInit.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#include "IMGUI/imgui.h"
#include "IMGUI/imgui_internal.h"
#include "IMGUI/imgui_impl_metal.h"
#include "IMGUI/imgui_impl_metal.h"
#import "Resources/Fonts/IconsFontAwesome6.h"
#import "Resources/Fonts/IconsFontAwesome6_Bytes.h"
#import "Resources/Fonts/din_alternate.hpp"
#include "IMGUI/Il2cpp.h"
#include <vector>
#include <string>
#define oxorany(x) x
#include "IL2CPP/Vector3.h"
#include "IL2CPP/Vector2.h"
#include "IL2CPP/Vector4.h"
#include "IL2CPP/Quaternion.h"
#include "IL2CPP/Matrix4x4.h"
#include "IL2CPP/Monostring.h"
#include "ESPConfig.h"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

#include "IL2CPP/Hooks.h"
#include "Resources/Textures/Logo/LogoData.h"
#include "DrawHelpers.mm"

// ImGui Color Variables - custom dark theme
static const ImVec4 COLOR_WINDOW_BG = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);    // #141414
static const ImVec4 COLOR_FRAME_BG = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);       // Match window background
static const ImVec4 COLOR_CHILD_BG = ImVec4(0.09f, 0.09f, 0.09f, 1.00f);       // Original column background
static const ImVec4 COLOR_BUTTON = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);        // Match window background
static const ImVec4 COLOR_BUTTON_HOVERED = ImVec4(0.12f, 0.12f, 0.12f, 1.00f);  // Darker hover
static const ImVec4 COLOR_BUTTON_ACTIVE = ImVec4(0.15f, 0.15f, 0.15f, 1.00f);   // Darker active
static const ImVec4 COLOR_TITLE_BG = ImVec4(0.09f, 0.09f, 0.09f, 1.00f);       // #171717
static const ImVec4 COLOR_TITLE_BG_ACTIVE = ImVec4(0.12f, 0.12f, 0.12f, 1.00f); // Darker active
static const ImVec4 COLOR_CHECK_MARK = ImVec4(1.00f, 0.00f, 0.28f, 1.00f);     // 255, 0, 72
static const ImVec4 COLOR_SLIDER_GRAB = ImVec4(1.00f, 0.00f, 0.28f, 1.00f);       // 255, 0, 72
static const ImVec4 COLOR_TEXT = ImVec4(0.92f, 0.92f, 0.92f, 1.00f);           // Light text
static const ImVec4 COLOR_BORDER = ImVec4(0.20f, 0.20f, 0.20f, 0.50f);         // Border
static const ImVec4 COLOR_SEPARATOR = ImVec4(0.20f, 0.20f, 0.20f, 0.50f);      // Separator
static const ImVec4 COLOR_HEADER = ImVec4(0.09f, 0.09f, 0.09f, 1.00f);        // #171717
static const ImVec4 COLOR_HEADER_HOVERED = ImVec4(0.12f, 0.12f, 0.12f, 1.00f); // Darker hover
static const ImVec4 COLOR_HEADER_ACTIVE = ImVec4(0.15f, 0.15f, 0.15f, 1.00f);  // Darker active
#import <Foundation/Foundation.h>
#import <os/log.h>
#import "pthread.h"
#include <math.h>
#include <deque>
#include <vector>
#include <fstream>

#include <vector>
#import <dlfcn.h>
#include <map>
#include <set>
#include <algorithm>
#include <string>
#import <QuartzCore/QuartzCore.h>

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include <unistd.h>
#include <string.h>
#include <float.h>


ImFont* verdana_smol;
#define kScale [UIScreen mainScreen].scale

static void* selectedCamera = nullptr;
static bool espInitialized = false;

static bool esp_line = false;
static bool esp_distance_enabled = false;
static bool esp_skeleton = false;
static bool esp_box_2d = false;
static bool esp_box_3d = false;
static bool esp_corners = false;
static int esp_line_position = 0;
static float ui_scale = 0.70f;

// Hacks Variables
static bool hack_fly = false;
static float hack_fly_speed = 5.0f;
static bool hack_telekill = false;
static int hack_telekill_dist = 8; // 8, 10, 100
static void* telekill_target = nullptr;
static float last_telekill_time = 0.0f;


void* getMainCamera() {
    if (!selectedCamera) {
        selectedCamera = Camera_get_main();
    }
    return selectedCamera;
}


void updateESPVariables(bool line, bool distance, bool skeleton, int linePos, bool box2d, bool box3d, bool corners) {
    esp_line = line;
    esp_distance_enabled = distance;
    esp_skeleton = skeleton;
    esp_line_position = linePos;
    esp_box_2d = box2d;
    esp_box_3d = box3d;
    esp_corners = corners;
}




struct PlayerData {
    void* object;
    void* gameObject;
    void* transform;
    Vector3 position;
    Vector3 w2sPosition;
    bool isVisible;
    
    PlayerData() : object(nullptr), gameObject(nullptr), transform(nullptr), isVisible(false) {}
};

#import <vector>
#import <string>
#import <set>

// Dynamic ESP Targeting
static std::string selected_assembly = PLAYER_ASSEMBLY_NAME;
static std::string selected_class = PLAYER_CLASS_NAME;
static std::vector<std::string> available_assemblies;
static std::vector<std::string> available_classes;
static int assembly_idx = -1;
static int class_idx = -1;

void UpdateAssemblies() {
    available_assemblies.clear();
    void* domain = IL2Cpp::il2cpp_domain_get();
    if (!domain) return;
    
    size_t size = 0;
    void** assemblies = IL2Cpp::il2cpp_domain_get_assemblies(domain, &size);
    if (!assemblies) return;
    
    std::set<std::string> assemblyNames;
    for (size_t i = 0; i < size; i++) {
        void* assembly = assemblies[i];
        if (!assembly) continue;
        void* image = (void*)IL2Cpp::il2cpp_assembly_get_image(assembly);
        if (!image) continue;
        const char* name = IL2Cpp::il2cpp_image_get_name(image);
        if (name) assemblyNames.insert(name);
    }
    
    for (const auto& name : assemblyNames) {
        available_assemblies.push_back(name);
        if (name == selected_assembly) {
            assembly_idx = available_assemblies.size() - 1;
        }
    }
}

void UpdateClasses(const std::string& assemblyName) {
    available_classes.clear();
    void* image = IL2Cpp::GetImage(assemblyName.c_str());
    if (!image) return;
    
    size_t count = IL2Cpp::il2cpp_image_get_class_count(image);
    std::set<std::string> classNames;
    
    for (size_t i = 0; i < count; i++) {
        void* klass = IL2Cpp::il2cpp_image_get_class(image, i);
        if (!klass) continue;
        
        const char* name = IL2Cpp::il2cpp_class_get_name(klass);
        const char* namespaze = IL2Cpp::il2cpp_class_get_namespace(klass);
        
        if (name) {
            std::string fullName = (namespaze && strlen(namespaze) > 0) ? (std::string(namespaze) + "." + std::string(name)) : std::string(name);
            classNames.insert(fullName);
        }
    }
    
    for (const auto& name : classNames) {
        available_classes.push_back(name);
        if (name == selected_class) {
            class_idx = available_classes.size() - 1;
        }
    }
}

void drawPlayerRootESP(ImDrawList* draw_list) {
    void* camera = Camera_get_main();
    if (!camera) return;
    
    Vector3 cameraPosition = Transform_get_position(GameObject_get_transform(Component_get_gameObject(camera)));
    
    static void* playerType = nullptr;
    static std::string lastClass = "";
    static std::string lastAssembly = "";

    if (!playerType || lastClass != selected_class || lastAssembly != selected_assembly) {
        std::string fullType = selected_class + ", " + selected_assembly;
        playerType = Type_GetType(String_CreateString(fullType.c_str()));
        lastClass = selected_class;
        lastAssembly = selected_assembly;
    }

    if (!playerType) return;
    
    monoArray<void**>* players = Object_FindObjectsOfType(playerType);
    if (!players || players->getLength() == 0) return;

    void* localPlayer = nullptr;
    telekill_target = nullptr;
    float minTargetDist = FLT_MAX;

    for (int i = 0; i < players->getLength(); i++) {
        void* object = players->getPointer()[i];
        if (!object) continue;
        
        bool isOwner = *(bool*)((uint64_t)object + 0x108);
        if (isOwner) {
            localPlayer = object;
            continue;
        }

        void* gameObject = Component_get_gameObject(object);
        if (!gameObject || !GameObject_get_activeInHierarchy(gameObject)) continue;
        
        void* transform = Component_get_transform(object);
        if (!transform) continue;
        
        Vector3 position = Transform_get_position(transform);
        if (position.x == 0 && position.y == 0 && position.z == 0) continue;
        
        float distToCamera = Vector3::Distance(cameraPosition, position);
        
        // Find Telekill Target (closest enemy)
        if (hack_telekill && localPlayer) {
            int localTeam = PlayerRoot_get_TeamId(localPlayer);
            int enemyTeam = PlayerRoot_get_TeamId(object);
            if (localTeam != enemyTeam && distToCamera < minTargetDist) {
                minTargetDist = distToCamera;
                telekill_target = object;
            }
        }

        if (!esp_line && !esp_distance_enabled && !esp_skeleton && !esp_box_2d && !esp_box_3d && !esp_corners) continue;
        if (distToCamera > ESP_MAX_DISTANCE) continue;

        Vector3 w2sPosition;
        bool isVisible;
        WorldToScreen(camera, position, w2sPosition, isVisible);
        if (!isVisible) continue;

        // --- Bounds & Skeleton Collection ---
        float minX = FLT_MAX, maxX = -FLT_MAX, minY = FLT_MAX, maxY = -FLT_MAX;
        bool hasSkeletonBounds = false;
        void* foundRenderer = nullptr;

        static void* componentType = nullptr;
        if (!componentType) componentType = Type_GetType(String_CreateString(CREATE_TYPE_STRING(COMPONENT_CLASS_NAME, COMPONENT_ASSEMBLY_NAME)));
        
        monoArray<void**>* components = GameObject_GetComponentsInternal(gameObject, componentType, false, false, false, false, nullptr);
        
        if (components) {
            for (int j = 0; j < components->getLength(); j++) {
                void* comp = components->getPointer()[j];
                if (!comp) continue;
                Il2CppClassMetadata* meta = *(Il2CppClassMetadata**)comp;
                if (!meta->name) continue;
                
                if (strstr(meta->name, "SkinnedMeshRenderer") || strstr(meta->name, "MeshRenderer")) {
                    foundRenderer = comp;
                    if (strstr(meta->name, "SkinnedMeshRenderer")) {
                        monoArray<void**>* bones = SkinnedMeshRenderer_get_bones(comp);
                        if (bones && bones->getLength() > MIN_BONE_COUNT) {
                            for (int b = 0; b < bones->getLength(); b++) {
                                void* bone = bones->getPointer()[b];
                                if (!bone) continue;
                                Vector3 bPos = Transform_get_position(bone);
                                Vector3 bSc; bool bVis;
                                WorldToScreen(camera, bPos, bSc, bVis);
                                if (bVis) {
                                    minX = std::min(minX, bSc.x); maxX = std::max(maxX, bSc.x);
                                    minY = std::min(minY, bSc.y); maxY = std::max(maxY, bSc.y);
                                    hasSkeletonBounds = true;
                                }
                            }
                        }
                    }
                    if (foundRenderer) break;
                }
            }
        }

        ImVec2 pts[8]; bool cornerVisible[8]; int visibleCorners = 0;
        if (!hasSkeletonBounds || esp_box_3d) {
            Vector3 center = position; center.y += 0.9f;
            Vector3 extent(0.4f, 0.9f, 0.4f);
            
            if (foundRenderer) {
                Bounds bounds = Renderer_get_bounds(foundRenderer);
                if (bounds.m_Extents.x > 0.01f) { center = bounds.m_Center; extent = bounds.m_Extents; }
            }
            
            Vector3 worldCorners[8] = {
                Vector3(center.x - extent.x, center.y - extent.y, center.z - extent.z),
                Vector3(center.x + extent.x, center.y - extent.y, center.z - extent.z),
                Vector3(center.x + extent.x, center.y - extent.y, center.z + extent.z),
                Vector3(center.x - extent.x, center.y - extent.y, center.z + extent.z),
                Vector3(center.x - extent.x, center.y + extent.y, center.z - extent.z),
                Vector3(center.x + extent.x, center.y + extent.y, center.z - extent.z),
                Vector3(center.x + extent.x, center.y + extent.y, center.z + extent.z),
                Vector3(center.x - extent.x, center.y + extent.y, center.z + extent.z)
            };
            
            for (int k = 0; k < 8; k++) {
                Vector3 sp; bool vis; WorldToScreen(camera, worldCorners[k], sp, vis);
                pts[k] = ImVec2(sp.x, sp.y); cornerVisible[k] = vis;
                if (vis) {
                    visibleCorners++;
                    if (!hasSkeletonBounds) {
                        minX = std::min(minX, sp.x); maxX = std::max(maxX, sp.x);
                        minY = std::min(minY, sp.y); maxY = std::max(maxY, sp.y);
                    }
                }
            }
        }

        if (!hasSkeletonBounds && visibleCorners < 3) continue;

        float dynamicThickness = std::max(0.8f, 1.2f - (distToCamera * 0.02f));
        ImU32 themePink = ESP_LINE_COLOR;

        if (esp_line) {
            ImVec2 start;
            switch (esp_line_position) {
                case 0: start = ImVec2(kWidth * 0.5f, 0.0f); break; 
                case 1: start = ImVec2(kWidth * 0.5f, kHeight * 0.5f); break; 
                default: start = ImVec2(kWidth * 0.5f, kHeight); break;
            }
            DrawESPLine(draw_list, start, ImVec2(w2sPosition.x, w2sPosition.y), themePink, ESP_LINE_THICKNESS);
        }

        if (esp_box_2d) DrawESPBox2D(draw_list, ImVec2(minX, minY), ImVec2(maxX, maxY), themePink, dynamicThickness);
        if (esp_box_3d) DrawESPBox3D(draw_list, pts, cornerVisible, themePink, dynamicThickness);
        if (esp_corners) DrawESPCorners(draw_list, ImVec2(minX, minY), ImVec2(maxX, maxY), std::max(8.0f, std::min(maxX-minX, maxY-minY)*0.25f), themePink, dynamicThickness);
        if (esp_distance_enabled) DrawESPDistance(draw_list, ImVec2(w2sPosition.x, w2sPosition.y), distToCamera, ESP_DISTANCE_COLOR);
    }
    
    // Apply Hacks
    if (localPlayer) {
        void* movement = *(void**)((uint64_t)localPlayer + 0xB0);
        void* transform = Component_get_transform(localPlayer);
        
        if (hack_fly && movement && transform) {
            *(float*)((uint64_t)movement + 0xBC) = 0.0f; // gravityForce = 0
            
            Vector3 pos = Transform_get_position(transform);
            // Simple FLY V2: Fly Up
            pos.y += hack_fly_speed * 0.05f; 
            Transform_set_position(transform, pos);
        }
        
        if (hack_telekill && telekill_target && transform) {
            void* targetTransform = Component_get_transform(telekill_target);
            if (targetTransform) {
                Vector3 targetPos = Transform_get_position(targetTransform);
                Vector3 myPos = targetPos;
                
                // Teleport behind or at distance
                myPos.y += 1.5f; // A bit above
                myPos.z -= (float)hack_telekill_dist; 
                
                Transform_set_position(transform, myPos);
            }
        }
    }

    if (esp_skeleton) DrawESPSkeleton(draw_list, camera, (void*)1, cameraPosition, 0.0f);
}


@interface ImGuiMTKView : MTKView
@end

@implementation ImGuiMTKView
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Check if any subviews (like our toggle button) handle the touch
    for (UIView *subview in self.subviews) {
        if (!subview.hidden && subview.userInteractionEnabled && [subview pointInside:[self convertPoint:point toView:subview] withEvent:event]) {
            return YES;
        }
    }

    ImGuiContext* Context = ImGui::GetCurrentContext();
    if (Context) {
        const ImVector<ImGuiWindow*>& Windows = Context->Windows;
        for (int i = 0; i < Windows.Size; ++i) {
            ImGuiWindow* CurrentWindow = Windows[i];
            if (!CurrentWindow) continue;

            if (CurrentWindow->Active && !(CurrentWindow->Flags & ImGuiWindowFlags_NoInputs)) {
                CGRect touchableArea = CGRectMake(CurrentWindow->Pos.x, CurrentWindow->Pos.y, CurrentWindow->Size.x, CurrentWindow->Size.y);
                if (CGRectContainsPoint(touchableArea, point)) {
                    return [super pointInside:point withEvent:event];
                }
            }
        }
    }
    return NO;
}
@end

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@property (nonatomic, strong) UIButton *toggleMenuButton;
@end

@implementation ImGuiDrawView

static bool MenDeal = true;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.device = MTLCreateSystemDefaultDevice();
        self.commandQueue = [self.device newCommandQueue];
    }
    return self;
}

- (void)loadView
{
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    ImGuiMTKView *mtkView = [[ImGuiMTKView alloc] initWithFrame:CGRectMake(0, 0, w, h) device:self.device];
    mtkView.delegate = self;
    mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    mtkView.backgroundColor = [UIColor clearColor];
    mtkView.paused = NO;
    mtkView.enableSetNeedsDisplay = NO;
    self.view = mtkView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    
    // Configure ImGui Style
    ImGuiStyle& style = ImGui::GetStyle();
    style.WindowRounding = 8.0f;
    style.FrameRounding = 4.0f;
    style.ChildRounding = 6.0f;
    style.GrabRounding = 4.0f;
    style.WindowPadding = ImVec2(0, 0);
    style.FramePadding = ImVec2(10, 8);
    style.ItemSpacing = ImVec2(10, 10);
    style.ScrollbarSize = 12.0f;
    style.ScrollbarRounding = 12.0f;
    
    // Set Colors
    style.Colors[ImGuiCol_WindowBg] = COLOR_WINDOW_BG;
    style.Colors[ImGuiCol_ChildBg] = COLOR_CHILD_BG;
    style.Colors[ImGuiCol_FrameBg] = COLOR_FRAME_BG;
    style.Colors[ImGuiCol_TitleBg] = COLOR_TITLE_BG;
    style.Colors[ImGuiCol_TitleBgActive] = COLOR_TITLE_BG_ACTIVE;
    style.Colors[ImGuiCol_Button] = COLOR_BUTTON;
    style.Colors[ImGuiCol_ButtonHovered] = COLOR_BUTTON_HOVERED;
    style.Colors[ImGuiCol_ButtonActive] = COLOR_BUTTON_ACTIVE;
    style.Colors[ImGuiCol_CheckMark] = COLOR_CHECK_MARK;
    style.Colors[ImGuiCol_SliderGrab] = COLOR_SLIDER_GRAB;
    style.Colors[ImGuiCol_SliderGrabActive] = COLOR_SLIDER_GRAB;
    style.Colors[ImGuiCol_Header] = COLOR_HEADER;
    style.Colors[ImGuiCol_HeaderHovered] = COLOR_HEADER_HOVERED;
    style.Colors[ImGuiCol_HeaderActive] = COLOR_HEADER_ACTIVE;
    style.Colors[ImGuiCol_Text] = COLOR_TEXT;
    style.Colors[ImGuiCol_Border] = COLOR_BORDER;
    style.Colors[ImGuiCol_Separator] = COLOR_SEPARATOR;

    // Load Fonts
    ImFontConfig font_cfg;
    font_cfg.FontDataOwnedByAtlas = false;
    
    // Load DIN Alternate for UI
    io.Fonts->AddFontFromMemoryTTF((void*)din_alternate_data, din_alternate_size, 18.0f, &font_cfg);
    
    // Load Icons
    static const ImWchar icons_ranges[] = { ICON_MIN_FA, ICON_MAX_16_FA, 0 };
    ImFontConfig icons_config;
    icons_config.MergeMode = true;
    icons_config.PixelSnapH = true;
    icons_config.FontDataOwnedByAtlas = false;
    io.Fonts->AddFontFromMemoryTTF((void*)IconsFontAwesome6_Bytes, sizeof(IconsFontAwesome6_Bytes), 16.0f, &icons_config, icons_ranges);

    ImGui_ImplMetal_Init(self.device);
    
    [self setupToggleMenuButton];
}

- (void)setupToggleMenuButton {
    self.toggleMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toggleMenuButton.frame = CGRectMake(20, 100, 50, 50);
    self.toggleMenuButton.layer.cornerRadius = 25;
    self.toggleMenuButton.backgroundColor = [UIColor colorWithRed:0.06f green:0.06f blue:0.06f alpha:0.85f];
    self.toggleMenuButton.layer.borderWidth = 2.0f;
    self.toggleMenuButton.layer.borderColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.28f alpha:1.0f].CGColor;
    self.toggleMenuButton.clipsToBounds = YES;
    
    // Get Logo for Button
    id<MTLTexture> mtlLogo = (__bridge id<MTLTexture>)(void *)getLogoTexture();
    if (mtlLogo) {
        UIImage *logoImg = createUIImageFromMTLTexture(mtlLogo);
        if (logoImg) {
            [self.toggleMenuButton setImage:logoImg forState:UIControlStateNormal];
            self.toggleMenuButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.toggleMenuButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        }
    }
    
    [self.toggleMenuButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    
    // Add Pan Gesture for dragging
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.toggleMenuButton addGestureRecognizer:panGesture];
    
    [self.view addSubview:self.toggleMenuButton];
}

- (void)toggleMenu {
    MenDeal = !MenDeal;
    [self.view bringSubviewToFront:self.toggleMenuButton];
    self.toggleMenuButton.userInteractionEnabled = YES;
}

- (void)handlePan:(UIPanGestureRecognizer *)pangesture {
    CGPoint translation = [pangesture translationInView:self.view];
    CGPoint newCenter = CGPointMake(pangesture.view.center.x + translation.x, pangesture.view.center.y + translation.y);
    newCenter.x = MAX(pangesture.view.frame.size.width/2, MIN(self.view.frame.size.width - pangesture.view.frame.size.width/2, newCenter.x));
    newCenter.y = MAX(pangesture.view.frame.size.height/2, MIN(self.view.frame.size.height - pangesture.view.frame.size.height/2, newCenter.y));
    pangesture.view.center = newCenter;
    [pangesture setTranslation:CGPointZero inView:self.view];
}

- (void)updateIOWithTouchEvent:(UIEvent *)event
{
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);
    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches)
    {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled)
        {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }

- (void)drawInitializationOverlay {
    ImGui::SetNextWindowPos(ImVec2(0, 0));
    ImGui::SetNextWindowSize(ImVec2(kWidth, kHeight));
    ImGui::SetNextWindowBgAlpha(0.0f);
    ImGuiWindowFlags window_flags = ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoSavedSettings;
    if (ImGui::Begin("InitializationOverlay", nullptr, window_flags)) {
        ImVec2 center = ImGui::GetMainViewport()->GetCenter();
        ImGui::SetNextWindowPos(center, ImGuiCond_Always, ImVec2(0.5f, 0.5f));
        ImGui::SetNextWindowSize(ImVec2(320, 160), ImGuiCond_Always);
        if (ImGui::Begin("InitPanel", nullptr, window_flags)) {
            ImGui::TextColored(ImVec4(0.0f, 0.0f, 0.0f, 1.0f), "Checking IL2CPP functions...");
            float progress = [IL2CPPInit getInitializationProgress];
            ImGui::ProgressBar(progress, ImVec2(-1, 0), "");
        }
        ImGui::End();
    }
    ImGui::End();
}

- (void)drawInMTKView:(MTKView*)view
{
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;
    CGFloat framebufferScale = view.window.screen.scale ?: UIScreen.mainScreen.scale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 120);
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor != nil)
    {
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        
        [IL2CPPInit updateInitializationProgress];
        if ([IL2CPPInit isShowingInitOverlay] && ![IL2CPPInit isInitializationComplete]) {
            [self drawInitializationOverlay];
        }
        
        static bool esp_enabled = false;
        ImDrawList* drawListESP = ImGui::GetBackgroundDrawList();
        if (esp_enabled && [IL2CPPInit isInitializationComplete]) {
            drawPlayerRootESP(drawListESP);
        }

        if (MenDeal == true && [IL2CPPInit isInitializationComplete])
        {
            ImFont* font = ImGui::GetFont();
            if (font) font->Scale = ui_scale;

            CGFloat x = (([UIScreen mainScreen].bounds.size.width) - 400) / 2;
            CGFloat y = (([UIScreen mainScreen].bounds.size.height) - 300) / 2;
            ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_FirstUseEver);
            ImGui::SetNextWindowSize(ImVec2(400, 300), ImGuiCond_FirstUseEver);
            
            ImGui::Begin("PAY TO WIN", &MenDeal, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse);
            
            ImDrawList* drawList = ImGui::GetWindowDrawList();
            ImVec2 windowPos = ImGui::GetWindowPos();
            ImVec2 windowSize = ImGui::GetWindowSize();
            float headerHeight = 25.0f;
            float footerHeight = 25.0f;
            float contentPadding = 10.0f;
            
            drawList->AddRectFilled(windowPos, ImVec2(windowPos.x + windowSize.x, windowPos.y + headerHeight), ImGui::ColorConvertFloat4ToU32(COLOR_TITLE_BG), ImGui::GetStyle().WindowRounding, ImDrawFlags_RoundCornersTop);
            drawList->AddText(ImVec2(windowPos.x + 10, windowPos.y + 5), ImGui::ColorConvertFloat4ToU32(COLOR_CHECK_MARK), "PAY TO WIN | MOALISA");

            ImGui::SetCursorPos(ImVec2(contentPadding, headerHeight + contentPadding));
            if (ImGui::BeginChild("##MainContent", ImVec2(windowSize.x - 20, windowSize.y - 60), false, ImGuiWindowFlags_NoBackground))
            {
                if (ImGui::BeginTabBar("MainTabBar"))
                {
                    if (ImGui::BeginTabItem(ICON_FA_EYE " ESP"))
                    {
                        ImGui::Checkbox("ESP Enable", &esp_enabled);
                        ImGui::Checkbox("ESP Line", &esp_line);
                        ImGui::Checkbox("ESP Distance", &esp_distance_enabled);
                        ImGui::Checkbox("ESP Skeleton", &esp_skeleton);
                        ImGui::Checkbox("ESP Box 2D", &esp_box_2d);
                        ImGui::Checkbox("ESP Box 3D", &esp_box_3d);
                        ImGui::Checkbox("ESP Corners", &esp_corners);
                        ImGui::EndTabItem();
                    }
                    if (ImGui::BeginTabItem(ICON_FA_BOLT " HACKS"))
                    {
                        ImGui::TextColored(ImVec4(1.0f, 0.0f, 0.28f, 1.0f), "Movement Hacks");
                        ImGui::Checkbox("FLY V2 (Fly Up)", &hack_fly);
                        if (hack_fly) ImGui::SliderFloat("Fly Speed", &hack_fly_speed, 1.0f, 20.0f);
                        
                        ImGui::Separator();
                        ImGui::TextColored(ImVec4(1.0f, 0.0f, 0.28f, 1.0f), "Combat Hacks");
                        ImGui::Checkbox("TELEKILL (Closest Enemy)", &hack_telekill);
                        if (hack_telekill) {
                            const char* dist_items[] = { "8 M", "10 M", "100 M" };
                            static int dist_idx = 0;
                            if (ImGui::Combo("Tele Distance", &dist_idx, dist_items, 3)) {
                                if (dist_idx == 0) hack_telekill_dist = 8;
                                else if (dist_idx == 1) hack_telekill_dist = 10;
                                else if (dist_idx == 2) hack_telekill_dist = 100;
                            }
                        }
                        ImGui::EndTabItem();
                    }
                    ImGui::EndTabBar();
                }
                ImGui::EndChild();
            }
            ImGui::End();
        }
        
        ImGui::Render();
        ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), commandBuffer, renderEncoder);
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
}

+ (void)showChange:(BOOL)open {
    MenDeal = open;
}

@end
