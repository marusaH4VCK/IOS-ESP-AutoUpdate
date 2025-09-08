#import "Esp/ImGuiDrawView.h"
#import "Init/IL2CPPInit.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#include "IMGUI/imgui.h"
#include "IMGUI/imgui_internal.h"
#include "IMGUI/imgui_impl_metal.h"
#include "IMGUI/zzz.h"
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


void drawPlayerRootESP(ImDrawList* draw_list) {
    if (!esp_line && !esp_distance_enabled && !esp_skeleton && !esp_box_2d && !esp_box_3d && !esp_corners) return;
    
    void* camera = getMainCamera();
    if (!isCameraValid(camera)) return;
    Vector3 cameraPosition = Transform_get_position(Component_get_transform(camera));
    
    if (esp_line || esp_distance_enabled || esp_box_2d || esp_box_3d || esp_corners) {
        void* playerRootType = Type_GetType(String_CreateString(CREATE_TYPE_STRING(PLAYER_CLASS_NAME, PLAYER_ASSEMBLY_NAME)));
        if (playerRootType) {
            monoArray<void**>* playerList = Object_FindObjectsOfType(playerRootType);
            if (playerList) {
                for (int i = 0; i < playerList->getLength(); i++) {
                    void* object = playerList->getPointer()[i];
                    if (!object) continue;
                    
                    void* gameObject = Component_get_gameObject(object);
                    if (!gameObject) continue;
                    if (!GameObject_get_activeInHierarchy(gameObject)) continue;
                    
                    void* transform = Component_get_transform(object);
                    if (!transform) continue;
                    
                    Vector3 position = Transform_get_position(transform);
                    if (position.x == 0 && position.y == 0 && position.z == 0) continue;
                    
                    Vector3 w2sPosition;
                    bool isVisible;
                    WorldToScreen(camera, position, w2sPosition, isVisible);
                    if (!isVisible) continue;
    
        if (esp_line) {
            ImVec2 start, target;
            

            switch (esp_line_position) {
                case 0: start = ImVec2(kWidth * 0.5f, 5.0f); break;
                case 1: start = ImVec2(kWidth * 0.5f, kHeight * 0.5f); break;
                default: start = ImVec2(kWidth * 0.5f, kHeight - 5.0f); break;
            }
            

            if (esp_line_position == 0) {
                Vector3 headPos = position + Vector3(0, 1.8f, 0);
                Vector3 headW2s; bool headVisible;
                WorldToScreen(camera, headPos, headW2s, headVisible);
                if (headVisible) {
                    target = ImVec2(headW2s.x, headW2s.y);
                } else {
                    target = ImVec2(w2sPosition.x, w2sPosition.y);
                }
            } else {
                target = ImVec2(w2sPosition.x, w2sPosition.y);
            }
            

            ImU32 lineColor = ESP_LINE_COLOR;
            float lineThickness = ESP_LINE_THICKNESS;
            
            draw_list->AddLine(start, target, IM_COL32(0, 0, 0, 100), lineThickness + 1.0f);
            draw_list->AddLine(start, target, lineColor, lineThickness);
        }
        
        if (esp_box_2d || esp_box_3d || esp_corners) {

            Vector3 c = position;
            Vector3 e = Vector3(0.5f, 1.0f, 0.5f);
            
            e.x = std::max(0.1f, std::min(e.x, 10.0f));
            e.y = std::max(0.1f, std::min(e.y, 10.0f));
            e.z = std::max(0.1f, std::min(e.z, 10.0f));
            
            float distance = Vector3::Distance(cameraPosition, c);
            float dynamicThickness = std::max(0.8f, 1.2f - (distance * 0.02f));
            float alpha = std::max(0.7f, 1.0f - (distance * 0.01f));
            ImU32 boxColor = IM_COL32(255, 255, 255, (int)(255 * alpha));
            

            Vector3 corners3D[8] = {
                Vector3(c.x - e.x, c.y - e.y, c.z - e.z),
                Vector3(c.x + e.x, c.y - e.y, c.z - e.z),
                Vector3(c.x + e.x, c.y - e.y, c.z + e.z),
                Vector3(c.x - e.x, c.y - e.y, c.z + e.z),
                Vector3(c.x - e.x, c.y + e.y, c.z - e.z),
                Vector3(c.x + e.x, c.y + e.y, c.z - e.z),
                Vector3(c.x + e.x, c.y + e.y, c.z + e.z),
                Vector3(c.x - e.x, c.y + e.y, c.z + e.z)
            };
            

            ImVec2 pts[8];
            bool cornerVisible[8];
            int visibleCorners = 0;
            
            for (int k = 0; k < 8; k++) {
                Vector3 sp; bool vis;
                WorldToScreen(camera, corners3D[k], sp, vis);
                pts[k] = ImVec2(sp.x, sp.y);
                cornerVisible[k] = vis;
                if (vis) visibleCorners++;
            }
            
            if (visibleCorners >= 3) {
                if (esp_box_2d) {

                    float minX = FLT_MAX, maxX = -FLT_MAX, minY = FLT_MAX, maxY = -FLT_MAX;
                    for (int k = 0; k < 8; k++) {
                        if (cornerVisible[k]) {
                            minX = std::min(minX, pts[k].x);
                            maxX = std::max(maxX, pts[k].x);
                            minY = std::min(minY, pts[k].y);
                            maxY = std::max(maxY, pts[k].y);
                        }
                    }
                    
                    float boxHeight = maxY - minY;
                    float boxWidth = maxX - minX;
                    
                    ImVec2 playerFeetPos(w2sPosition.x, w2sPosition.y);
                    ImVec2 boxCenter(playerFeetPos.x, playerFeetPos.y - boxHeight * 0.5f);
                    
                    ImVec2 corners[4] = {
                        ImVec2(boxCenter.x - boxWidth * 0.5f, boxCenter.y - boxHeight * 0.5f),
                        ImVec2(boxCenter.x + boxWidth * 0.5f, boxCenter.y - boxHeight * 0.5f),
                        ImVec2(boxCenter.x + boxWidth * 0.5f, boxCenter.y + boxHeight * 0.5f),
                        ImVec2(boxCenter.x - boxWidth * 0.5f, boxCenter.y + boxHeight * 0.5f)
                    };
                    
                    for (int j = 0; j < 4; j++) {
                        int next = (j + 1) % 4;
                        draw_list->AddLine(corners[j], corners[next], boxColor, dynamicThickness);
                    }
                }
                
                if (esp_box_3d) {

                    Vector3 adjustedCenter = Vector3(position.x, position.y + e.y, position.z);
                    
                    Vector3 corners3D_adjusted[8] = {
                        Vector3(adjustedCenter.x - e.x, adjustedCenter.y - e.y, adjustedCenter.z - e.z),
                        Vector3(adjustedCenter.x + e.x, adjustedCenter.y - e.y, adjustedCenter.z - e.z),
                        Vector3(adjustedCenter.x + e.x, adjustedCenter.y - e.y, adjustedCenter.z + e.z),
                        Vector3(adjustedCenter.x - e.x, adjustedCenter.y - e.y, adjustedCenter.z + e.z),
                        Vector3(adjustedCenter.x - e.x, adjustedCenter.y + e.y, adjustedCenter.z - e.z),
                        Vector3(adjustedCenter.x + e.x, adjustedCenter.y + e.y, adjustedCenter.z - e.z),
                        Vector3(adjustedCenter.x + e.x, adjustedCenter.y + e.y, adjustedCenter.z + e.z),
                        Vector3(adjustedCenter.x - e.x, adjustedCenter.y + e.y, adjustedCenter.z + e.z)
                    };
                    
                    ImVec2 pts_adjusted[8];
                    bool cornerVisible_adjusted[8];
                    int visibleCorners_adjusted = 0;
                    
                    for (int k = 0; k < 8; k++) {
                        Vector3 sp; bool vis;
                        WorldToScreen(camera, corners3D_adjusted[k], sp, vis);
                        pts_adjusted[k] = ImVec2(sp.x, sp.y);
                        cornerVisible_adjusted[k] = vis;
                        if (vis) visibleCorners_adjusted++;
                    }
                    
                    if (visibleCorners_adjusted >= 3) {
                        int edges[12][2] = {
                            {0,1}, {1,2}, {2,3}, {3,0},
                            {4,5}, {5,6}, {6,7}, {7,4},
                            {0,4}, {1,5}, {2,6}, {3,7}
                        };
                        
                        for (int eidx = 0; eidx < 12; eidx++) {
                            int a = edges[eidx][0];
                            int b = edges[eidx][1];
                            if (cornerVisible_adjusted[a] && cornerVisible_adjusted[b]) {
                                draw_list->AddLine(pts_adjusted[a], pts_adjusted[b], boxColor, dynamicThickness);
                            }
                        }
                    }
                }
                
                if (esp_corners) {

                    float minX = FLT_MAX, maxX = -FLT_MAX, minY = FLT_MAX, maxY = -FLT_MAX;
                    for (int k = 0; k < 8; k++) {
                        if (cornerVisible[k]) {
                            minX = std::min(minX, pts[k].x);
                            maxX = std::max(maxX, pts[k].x);
                            minY = std::min(minY, pts[k].y);
                            maxY = std::max(maxY, pts[k].y);
                        }
                    }
                    
                    float cornerWidth = maxX - minX;
                    float cornerHeight = maxY - minY;
                    
                    ImVec2 playerFeetPos(w2sPosition.x, w2sPosition.y);
                    ImVec2 cornerCenter(playerFeetPos.x, playerFeetPos.y - cornerHeight * 0.5f);
                    
                    ImVec2 corners[4] = {
                        ImVec2(cornerCenter.x - cornerWidth * 0.5f, cornerCenter.y - cornerHeight * 0.5f),
                        ImVec2(cornerCenter.x + cornerWidth * 0.5f, cornerCenter.y - cornerHeight * 0.5f),
                        ImVec2(cornerCenter.x + cornerWidth * 0.5f, cornerCenter.y + cornerHeight * 0.5f),
                        ImVec2(cornerCenter.x - cornerWidth * 0.5f, cornerCenter.y + cornerHeight * 0.5f)
                    };
                    
                    float cornerLength = std::max(10.0f, std::min(cornerWidth, cornerHeight) * 0.3f);
                    

                    draw_list->AddLine(corners[0], ImVec2(corners[0].x + cornerLength, corners[0].y), boxColor, dynamicThickness);
                    draw_list->AddLine(corners[0], ImVec2(corners[0].x, corners[0].y + cornerLength), boxColor, dynamicThickness);
                    

                    draw_list->AddLine(corners[1], ImVec2(corners[1].x - cornerLength, corners[1].y), boxColor, dynamicThickness);
                    draw_list->AddLine(corners[1], ImVec2(corners[1].x, corners[1].y + cornerLength), boxColor, dynamicThickness);
                    

                    draw_list->AddLine(corners[2], ImVec2(corners[2].x - cornerLength, corners[2].y), boxColor, dynamicThickness);
                    draw_list->AddLine(corners[2], ImVec2(corners[2].x, corners[2].y - cornerLength), boxColor, dynamicThickness);
                    

                    draw_list->AddLine(corners[3], ImVec2(corners[3].x + cornerLength, corners[3].y), boxColor, dynamicThickness);
                    draw_list->AddLine(corners[3], ImVec2(corners[3].x, corners[3].y - cornerLength), boxColor, dynamicThickness);
                }
            }
        }
        
        if (esp_distance_enabled) {
            float distance = Vector3::Distance(position, cameraPosition);
            std::string distanceStr = std::to_string((int)distance) + "M";
            ImU32 distanceColor = ESP_DISTANCE_COLOR;
            draw_list->AddText(ImVec2(w2sPosition.x + 5, w2sPosition.y - 10), distanceColor, distanceStr.c_str());
        }
                }
            }
        }
    }
    

    if (esp_skeleton) {
        void* GameObjectType = Type_GetType(String_CreateString(CREATE_TYPE_STRING(GAMEOBJECT_CLASS_NAME, GAMEOBJECT_ASSEMBLY_NAME)));
        if (GameObjectType) {
            monoArray<void**>* allGameObjects = Object_FindObjectsOfType(GameObjectType);
            if (allGameObjects) {
                for (int i = 0; i < allGameObjects->getLength(); i++) {
                    void* gameObject = allGameObjects->getPointer()[i];
                    if (!gameObject || !GameObject_get_activeInHierarchy(gameObject)) continue;
                    
                    void* transform = GameObject_get_transform(gameObject);
                    if (!transform) continue;
                    
                    Vector3 position = Transform_get_position(transform);
                    if (position.x == 0 && position.y == 0 && position.z == 0) continue;
                    
                    float distanceToCamera = Vector3::Distance(cameraPosition, position);
                    if (distanceToCamera > ESP_MAX_DISTANCE) continue;
            
                    void* foundSkinned = nullptr;
                    void* ComponentType = Type_GetType(String_CreateString(CREATE_TYPE_STRING(COMPONENT_CLASS_NAME, COMPONENT_ASSEMBLY_NAME)));
                    monoArray<void**>* componentArrayForDraw = GameObject_GetComponentsInternal(gameObject, ComponentType, false, false, false, false, nullptr);
                    
                    if (componentArrayForDraw) {
                        for (int jj = 0; jj < componentArrayForDraw->getLength(); jj++) {
                            void* compPtr = componentArrayForDraw->getPointer()[jj];
                            if (!compPtr) continue;
                            Il2CppClassMetadata* meta = *(Il2CppClassMetadata**)compPtr;
                            const char* klass = meta->name;
                            const char* namespaze = meta->namespaze;
                            std::string typeKey = (namespaze && strlen(namespaze) > 0) ? (std::string(namespaze) + "." + std::string(klass)) : std::string(klass);
                            
                            if (typeKey.find(SKINNED_MESH_RENDERER_CLASS_NAME) != std::string::npos) {
                                foundSkinned = compPtr;
                                break;
                            }
                        }
                    }
                    
                    if (foundSkinned) {
                        monoArray<void**>* bones = SkinnedMeshRenderer_get_bones(foundSkinned);
                        if (bones && bones->getLength() > MIN_BONE_COUNT) {
                            const int boneCount = bones->getLength();
                            
                            struct BoneInfo {
                                void* transform;
                                int parentIndex;
                                Vector3 worldPos;
                                ImVec2 screenPos;
                                bool isVisible;
                                bool isImportant;
                                float importance;
                            };
                            
                            std::vector<BoneInfo> boneInfos;
                            boneInfos.reserve(boneCount);
                            
                            for (int bi = 0; bi < boneCount; bi++) {
                                void* boneTr = bones->getPointer()[bi];
                                if (!boneTr) continue;
                                
                                BoneInfo info = {};
                                info.transform = boneTr;
                                info.worldPos = Transform_get_position(boneTr);
                                info.parentIndex = -1;
                                
                                void* parentTr = Transform_get_parent(boneTr);
                                if (parentTr) {
                                    for (int pi = 0; pi < boneCount; pi++) {
                                        if (bones->getPointer()[pi] == parentTr) {
                                            info.parentIndex = pi;
                                            break;
                                        }
                                    }
                                }
                                
                                Vector3 sp; bool vis;
                                WorldToScreen(camera, info.worldPos, sp, vis);
                                info.screenPos = ImVec2(sp.x, sp.y);
                                info.isVisible = vis;
                                
                                int childCount = Transform_get_childCount(boneTr);
                                if (childCount >= 3) info.importance = 1.0f;
                                else if (childCount == 2) info.importance = 0.8f;
                                else if (childCount == 1) info.importance = 0.6f;
                                else info.importance = 0.4f;
                                
                                info.isImportant = (info.importance >= 0.8f);
                                boneInfos.push_back(info);
                            }
                            
                            for (size_t bi = 0; bi < boneInfos.size(); bi++) {
                                const BoneInfo& bone = boneInfos[bi];
                                
                                if (bone.parentIndex == -1 || bone.parentIndex >= (int)boneInfos.size()) continue;
                                if (!bone.isVisible) continue;
                                
                                const BoneInfo& parent = boneInfos[bone.parentIndex];
                                if (!parent.isVisible) continue;
                                
                                float boneDist = Vector3::Distance(bone.worldPos, parent.worldPos);
                                float maxDist = bone.isImportant ? MAX_BONE_DISTANCE_IMPORTANT : MAX_BONE_DISTANCE_NORMAL;
                                if (boneDist < 0.01f || boneDist > maxDist) continue;
                                
                                float finalThickness = ESP_SKELETON_THICKNESS;
                                
                                ImU32 boneColor;
                                if (bone.isImportant) {
                                    boneColor = ESP_SKELETON_COLOR_IMPORTANT;
                                } else {
                                    boneColor = ESP_SKELETON_COLOR_NORMAL;
                                }
                                
                                float distance = Vector3::Distance(cameraPosition, bone.worldPos);
                                float alpha = std::max(0.4f, 1.0f - (distance * 0.02f));
                                boneColor = IM_COL32(
                                    (boneColor >> IM_COL32_R_SHIFT) & 0xFF,
                                    (boneColor >> IM_COL32_G_SHIFT) & 0xFF,
                                    (boneColor >> IM_COL32_B_SHIFT) & 0xFF,
                                    (int)(255 * alpha)
                                );
                                
                                ImVec2 boneScreenPos = bone.screenPos;
                                ImVec2 parentScreenPos = parent.screenPos;
                                
                                draw_list->AddLine(parentScreenPos, boneScreenPos, boneColor, finalThickness);
                            }
                        }
                    }
                }
            }
        }
    }
    
}



@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@end


@implementation ImGuiDrawView

static bool show_s0 = false;




static bool MenDeal = true;


- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];

    if (!self.device) abort();

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;

    ImGui::StyleColorsLight();
    
    ImGuiStyle& style = ImGui::GetStyle();
    style.WindowRounding = 12.0f;
    style.ChildRounding = 12.0f;
    style.FrameRounding = 12.0f;
    style.PopupRounding = 12.0f;
    style.ScrollbarRounding = 12.0f;
    style.GrabRounding = 12.0f;
    style.TabRounding = 4.0f;
    style.WindowBorderSize = 0.0f;
    style.ChildBorderSize = 0.0f;
    style.PopupBorderSize = 0.0f;
    style.FrameBorderSize = 0.0f;
    
    ImFont* font = io.Fonts->AddFontFromMemoryCompressedTTF((void*)zzz_compressed_data, zzz_compressed_size, 60.0f, NULL, io.Fonts->GetGlyphRangesVietnamese());
    
    ImGui_ImplMetal_Init(_device);

    return self;
}

+ (void)showChange:(BOOL)open
{
    MenDeal = open;
}

- (MTKView *)mtkView
{
    return (MTKView *)self.view;
}

- (void)loadView
{

 

    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor clearColor];
    self.mtkView.clipsToBounds = YES;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [IL2CPPInit startPrecheck];
    });
}



#pragma mark - Interaction

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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

#pragma mark - Initialization Overlay

- (void)drawInitializationOverlay {
    ImGui::SetNextWindowPos(ImVec2(0, 0));
    ImGui::SetNextWindowSize(ImVec2(kWidth, kHeight));
    ImGui::SetNextWindowBgAlpha(0.0f);
    
    ImGuiWindowFlags window_flags = ImGuiWindowFlags_NoTitleBar | 
                                   ImGuiWindowFlags_NoResize | 
                                   ImGuiWindowFlags_NoMove | 
                                   ImGuiWindowFlags_NoScrollbar | 
                                   ImGuiWindowFlags_NoScrollWithMouse |
                                   ImGuiWindowFlags_NoCollapse |
                                   ImGuiWindowFlags_NoSavedSettings;
    
    if (ImGui::Begin("InitializationOverlay", nullptr, window_flags)) {
        ImVec2 center = ImGui::GetMainViewport()->GetCenter();
        ImGui::SetNextWindowPos(center, ImGuiCond_Always, ImVec2(0.5f, 0.5f));
        ImGui::SetNextWindowSize(ImVec2(320, 160), ImGuiCond_Always);
        
        ImGuiWindowFlags panel_flags = ImGuiWindowFlags_NoTitleBar | 
                                      ImGuiWindowFlags_NoResize | 
                                      ImGuiWindowFlags_NoMove | 
                                      ImGuiWindowFlags_NoScrollbar | 
                                      ImGuiWindowFlags_NoScrollWithMouse |
                                      ImGuiWindowFlags_NoCollapse |
                                      ImGuiWindowFlags_NoSavedSettings;
        
        if (ImGui::Begin("InitPanel", nullptr, panel_flags)) {
            ImGui::TextColored(ImVec4(0.0f, 0.0f, 0.0f, 1.0f), "Checking IL2CPP functions and symbols...");
            ImGui::Spacing();
            
            float progress = [IL2CPPInit getInitializationProgress];
            ImGui::ProgressBar(progress, ImVec2(-1, 0), "");
            ImGui::Spacing();
            
            const char* currentLabel = [IL2CPPInit getCurrentCheckLabel];
            int dotCount = [IL2CPPInit getDotCount];
            std::string dots(dotCount, '.');
            std::string labelText = std::string("Checking: ") + currentLabel + dots;
            ImGui::TextColored(ImVec4(0.0f, 0.0f, 0.0f, 1.0f), "%s", labelText.c_str());
            
            static float spinnerAngle = 0.0f;
            spinnerAngle += 0.1f;
            if (spinnerAngle > 6.28f) spinnerAngle = 0.0f;
            
            ImVec2 spinnerPos = ImGui::GetCursorScreenPos();
            ImGui::GetWindowDrawList()->AddText(
                ImVec2(spinnerPos.x + 150, spinnerPos.y + 20),
                ImGui::GetColorU32(ImVec4(0.0f, 0.0f, 0.0f, 1.0f)),
                "⟳"
            );
        }
        ImGui::End();
    }
    ImGui::End();
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(MTKView*)view
{
   
    
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;

    CGFloat framebufferScale = view.window.screen.scale ?: UIScreen.mainScreen.scale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 120);
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    

    static bool esp_enabled = false;
    static bool esp_box_2d = false;
    static bool esp_box_3d = false;
    static bool esp_corners = false;
    
        
        if (MenDeal == true) {
            [self.view setUserInteractionEnabled:YES];
        } else if (MenDeal == false) {
            [self.view setUserInteractionEnabled:NO];
        }

        MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
        if (renderPassDescriptor != nil)
        {
            id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
            [renderEncoder pushDebugGroup:@"ImGui Jane"];

            ImGui_ImplMetal_NewFrame(renderPassDescriptor);
            ImGui::NewFrame();
            
            [IL2CPPInit updateInitializationProgress];
            if ([IL2CPPInit isShowingInitOverlay] && ![IL2CPPInit isInitializationComplete]) {
                [self drawInitializationOverlay];
            }
            
            ImFont* font = ImGui::GetFont();
            if (font && font->FontSize > 0) {
                font->Scale = 15.f / font->FontSize;
            }
            
            CGFloat x = (([UIScreen mainScreen].bounds.size.width) - 360) / 2;
            CGFloat y = (([UIScreen mainScreen].bounds.size.height) - 300) / 2;
            
            ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_FirstUseEver);
            ImGui::SetNextWindowSize(ImVec2(400, 300), ImGuiCond_FirstUseEver);
            
            if (MenDeal == true && [IL2CPPInit isInitializationComplete])
            {                
                ImGui::Begin("IL2CPP ESP Auto Update Unity3D Games", &MenDeal);
                ImGui::Text("IL2CPP ESP Auto Update Unity3D Games");
                ImGui::Text("No Jailbreak Required - No JIT Required");
                
                if (ImGui::BeginTabBar("MainTabBar"))
                {
                    if (ImGui::BeginTabItem("ESP"))
                    {
                        ImGui::Checkbox("ESP Enable", &esp_enabled);
                        ImGui::Separator();
                        
                        if (esp_enabled) {
                            ImGui::Checkbox("ESP Line", &esp_line);
                            if (esp_line) {
                                static int esp_line_selection = 0;
                                const char* esp_line_items[] = { "Top", "Middle", "Bottom" };
                                
                                if (ImGui::BeginCombo("Line Position", esp_line_items[esp_line_selection])) {
                                    for (int i = 0; i < IM_ARRAYSIZE(esp_line_items); i++) {
                                        bool is_selected = (esp_line_selection == i);
                                        if (ImGui::Selectable(esp_line_items[i], is_selected)) {
                                            esp_line_selection = i;
                                        }
                                        if (is_selected) {
                                            ImGui::SetItemDefaultFocus();
                                        }
                                    }
                                    ImGui::EndCombo();
                                }
                                
                                esp_line_position = esp_line_selection;
                            }
                            
                            static bool esp_box_enabled = false;
                            ImGui::Checkbox("ESP Box", &esp_box_enabled);
                            if (esp_box_enabled) {
                                static int esp_box_selection = 0;
                                const char* esp_box_items[] = { "2D Box", "3D Box", "Corners Box" };
                                
                                if (ImGui::BeginCombo("Box Type", esp_box_items[esp_box_selection])) {
                                    for (int i = 0; i < IM_ARRAYSIZE(esp_box_items); i++) {
                                        bool is_selected = (esp_box_selection == i);
                                        if (ImGui::Selectable(esp_box_items[i], is_selected)) {
                                            esp_box_selection = i;
                                        }
                                        if (is_selected) {
                                            ImGui::SetItemDefaultFocus();
                                        }
                                    }
                                    ImGui::EndCombo();
                                }
                                
                                esp_box_2d = (esp_box_selection == 0);
                                esp_box_3d = (esp_box_selection == 1);
                                esp_corners = (esp_box_selection == 2);
                            } else {
                                esp_box_2d = false;
                                esp_box_3d = false;
                                esp_corners = false;
                            }
                            
                            ImGui::Checkbox("ESP Distance", &esp_distance_enabled);
                            
                            ImGui::Checkbox("ESP Skeleton", &esp_skeleton);
                            
                            updateESPVariables(esp_line, esp_distance_enabled, esp_skeleton, esp_line_position, esp_box_2d, esp_box_3d, esp_corners);
                        }
                        
                        ImGui::Spacing();
                        ImGui::Separator();
                        
                        ImGui::TextColored(ImVec4(0.0f, 0.7f, 1.0f, 1.0f), "Credits:");
                        ImGui::Text("Main Developer: AlexZero");
                        ImGui::Text("ImGui Template: Little 34306");
                        ImGui::Text("IL2CPP Framework: Hao Dam (damduchao)");
                        ImGui::EndTabItem();
                    }
                    
                    
                    ImGui::EndTabBar();
                }

                ImGui::End();
                
            }
            ImDrawList* draw_list = ImGui::GetBackgroundDrawList();

            if (esp_enabled) {
                drawPlayerRootESP(draw_list);
            }



            ImGui::Render();
            ImDrawData* draw_data = ImGui::GetDrawData();
            ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
          
            [renderEncoder popDebugGroup];
            [renderEncoder endEncoding];

            [commandBuffer presentDrawable:view.currentDrawable];
        }

        [commandBuffer commit];
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size
{
    
}

@end

