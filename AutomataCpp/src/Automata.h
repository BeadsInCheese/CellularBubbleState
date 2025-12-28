#ifndef AUTOMATA
#define AUTOMATA

#include <godot_cpp/classes/node2d.hpp>
#include <map>
#include <vector>

static constexpr int o = 5; //# shortcut for Any
static constexpr int t = -1;   //# shortcut for Tower
static constexpr int b = -2;   //# shortcut for Bubble

struct rule{
    uint8_t matrixSize=3;
    std::array<int_fast8_t,25> rows;
    int_fast8_t result;
    unsigned int hash()const;
};

namespace std{
    template<>
    struct hash<rule>{
    inline size_t operator()(const rule& x)const{
        return x.hash();
    }
    };
}
#define MEMSIZE 112
struct arena{
    std::array<rule,MEMSIZE> ruleArray;
    void push_back(rule element);
    void clear();
    int ptr=0;
    rule& operator[](int index){
        return ruleArray[index];
    }
    size_t size();
};
int unsafePow(unsigned int a,unsigned int b);
bool operator ==(const rule&,const rule&);


namespace godot {

  
class Automata : public Node2D {
    GDCLASS(Automata, Node2D)

private:
    double time_passed;

   
    
protected:
    static void _bind_methods();

public:

    void printRules();
    void clearRuleset();
    void addRule(Array Rules,int result);
    void compileRuleset();
    void removeDuplicateRules();
    rule rotate(rule& r);
    arena getRules();
    inline int_fast8_t getTile(int xpos,int ypos,int xsize,int ysize,std::array<int_fast8_t,144> &board);
    inline bool matchMatrix(int posx,int posy,std::array<int_fast8_t,144> &board,rule &r);
    int_fast8_t evaluateTile(int xpos,int ypos,std::array<int_fast8_t,144> &board,Array &target);
    void runStep(std::array<int_fast8_t,144> &board,Array &target);
    Array AutomataStep(Array board);




    Automata();
    ~Automata();

    
    void _process(double delta) override;
};
}



#endif
