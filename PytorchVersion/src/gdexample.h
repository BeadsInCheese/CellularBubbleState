#ifndef EXAMPLE
#define EXAMPLE
#include <godot_cpp/classes/node2D.hpp>
#include <torch.h>
namespace godot{
class GDExample:public Node2D{
    GDCLASS(GDExample,Node2D)
    private:
        double time_passed;
    protected:
    static void _bind_methods();
public:
    GDExample();
    int createSession(Array godot_array);
    void predict(Array arr);
    void stringtest(String test);
    void save(String name);
    void load(String name);
    void train(int epocs,Array XData,Array YData);
    void modelAddReLU();
    void modelAddConv2D(String name,String activation,int filters,int kernelSize,int stride);
    void modelAddSoftMax(int input);
    void modelAddLinear(String name,String activation,int x,int y);
    void modelAddMaxPool(String name,String activation,int size);
    
    ~GDExample();
    void _process(double delta) override;
private:
    torch::Tensor convertToTensor(Array godot_array);


};


}


#endif