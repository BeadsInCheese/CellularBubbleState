#include "gdexample.h"
#include <torch.h>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
using namespace godot;

enum activationType{relu};
struct layer{
    layer(std::string name,int l,activationType activation,int param1,int param2,int param3): name(name),l(l), activation(activation),param1(param1),param2(param2),param3(param3){};
    std::string name;
     int l;
     int activation;
     int param1;
     int param2;
     int param3;

};
enum layerType{
    Conv2D,Dense,maxPool

};

std::vector<layer> layers;
void GDExample::_bind_methods(){
    ClassDB::bind_method(D_METHOD("createSession"), &GDExample::createSession);
    ClassDB::bind_method(D_METHOD("model_save"), &GDExample::save);
    ClassDB::bind_method(D_METHOD("model_load"), &GDExample::load);

    ClassDB::bind_method(D_METHOD("modelAddReLU"), &GDExample::modelAddReLU);
    ClassDB::bind_method(D_METHOD("modelAddConv2D"), &GDExample::modelAddConv2D);
    ClassDB::bind_method(D_METHOD("modelAddSoftMax"), &GDExample::modelAddSoftMax);
    ClassDB::bind_method(D_METHOD("modelAddLinear"), &GDExample::modelAddLinear);
    ClassDB::bind_method(D_METHOD("modelAddMaxPool"), &GDExample::modelAddMaxPool);
     ClassDB::bind_method(D_METHOD("stringtest"), &GDExample::stringtest);
      ClassDB::bind_method(D_METHOD("train"), &GDExample::train);
      ClassDB::bind_method(D_METHOD("predict"), &GDExample::predict);

}

void GDExample::modelAddReLU(){}
void GDExample::modelAddConv2D(String name,String activation,int filters,int kernelSize,int stride){
    layers.push_back(layer(std::string(name.utf8().get_data()),Conv2D,relu,filters,kernelSize,stride));

}
void GDExample::modelAddSoftMax(int input){}
void GDExample::modelAddLinear(String name,String activation,int x,int y){
    layers.push_back(layer(std::string(name.utf8().get_data()),Dense,relu,x,y,0));
}
void GDExample::modelAddMaxPool(String name,String activation,int size){}
    


struct net : torch::nn::Module {
    torch::nn::ModuleList networklayers;

    net()  {
        networklayers = register_module("layers", torch::nn::ModuleList());
        for (const auto l : layers) {
            switch (l.l) {
                case Dense: {
                    auto linear = torch::nn::Linear(l.param1, l.param2);
                    //register_module(l.name, linear);
                    networklayers->push_back(linear);
                    break;
                }
                // Handle other layer types (Conv2D, etc.) similarly
                default:
                    break;
            }
        }
    }

    torch::Tensor forward(torch::Tensor x) {
        for (size_t i = 0;  i<networklayers->size(); ++i) {
            auto current_layer = networklayers[i];
            if (auto linear = current_layer->as<torch::nn::Linear>()) {
                x = linear->forward(x);
                // Apply activation based on stored configuration
                if (i != networklayers->size() - 1) {
                    x = torch::relu(x);
                }else{
                    x=torch::sigmoid(x);
                }
                
            }
            // Handle other layer types here
        }
        return x;
    }

       // Declare two Linear submodules.
  //  torch::nn::Linear fc1{nullptr}, fc2{nullptr};

};
void GDExample::stringtest(String test){
    UtilityFunctions::print(test);


}

std::shared_ptr<net> model;
void GDExample::train(int epocs,Array XData,Array YData){
    auto X_train=convertToTensor(XData);
    auto y_train=convertToTensor(YData);
    std::ostringstream stream;
    stream << X_train;
    std::string tensor_string = stream.str();
    UtilityFunctions::print(tensor_string.c_str());
    auto criterion = torch::nn::BCELoss();
    auto optimizer = torch::optim::Adam(model->parameters(), torch::optim::AdamOptions(0.01));
    for (size_t epoch = 0; epoch < epocs; ++epoch) {
        model->train();
        optimizer.zero_grad();
        auto outputs = model->forward(X_train);
        auto loss  = criterion(outputs.squeeze(1), y_train.squeeze(1));
        loss.backward();
        optimizer.step();

        if ((epoch + 1) % 10 == 0) {
            std::string message = "Epoch [" + std::to_string(epoch + 1) + "/"+std::to_string(epocs)+"], Loss: " + std::to_string(loss.item<float>());
                
            UtilityFunctions::print( message.c_str());
        }

    }
}

int GDExample::createSession(Array godot_array) {

    //auto net=torch::nn::Sequential(torch::nn::Linear(2,2),torch::nn::Tanh(),torch::nn::Linear(2,2),torch::nn::Tanh(),torch::nn::Linear(2,1));
    // Add layers dynamically
auto options = torch::TensorOptions().dtype(torch::kFloat32);
auto X_train = torch::tensor({{0.0, 0.0}, {0.0, 1.0}, {1.0, 0.0}, {1.0, 1.0}}, options);
auto y_train = torch::tensor({{0.0}, {1.0}, {1.0}, {0.0}}, options);


    model = std::make_shared<net>();

    return 0;
   

}
    torch::Tensor convertNestedArray(const godot::Array array) {
        std::vector<torch::Tensor> tensors;
        tensors.reserve(array.size());
        for (int i = 0; i < array.size(); ++i) {
            if (array[i].get_type() == godot::Variant::ARRAY) {
                tensors.push_back(convertNestedArray(array[i]));
            } else {
                tensors.push_back(torch::tensor(static_cast<float>(array[i])));
            }
        }
        return torch::stack(tensors);
    }
torch::Tensor GDExample::convertToTensor(const godot::Array godot_array) {
    // Helper function to recursively convert nested arrays


    // Convert the top-level array
    return convertNestedArray(godot_array);
}
GDExample::GDExample(){

}
GDExample::~GDExample(){

    
}

void GDExample::_process(double delta){


}
void GDExample::predict(Array arr){
{
    std::ostringstream stream;
    stream << convertToTensor(arr);
    std::string tensor_string = stream.str();
    UtilityFunctions::print(tensor_string.c_str());
    }
        UtilityFunctions::print("----------------------");
    auto predictions = model->forward(convertToTensor(arr));
    {
    std::ostringstream stream;
    stream << predictions;
    std::string tensor_string = stream.str();
    UtilityFunctions::print(tensor_string.c_str());
    }
}
void GDExample::save(String name){
    torch::save(model, (name+".pt").utf8().get_data());

}
void GDExample::load(String name){
    torch::load(model, (name+".pt").utf8().get_data());

}