#ifndef AUTOMATA
#define AUTOMATA

#include <godot_cpp/classes/node2d.hpp>
#include <map>
#include <vector>
#include <thread>
#include <chrono>

static constexpr int o = 5; //# shortcut for Any
static constexpr int t = -1;   //# shortcut for Tower
static constexpr int b = -2;   //# shortcut for Bubble
#define boardsize 12
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
class Automata;
struct work{
    int start;
    int end;

};
class threadPool;
class worker{
    public:
    std::thread workerThread;
    threadPool* pool;
    bool executing=false;
    work wrk;
    worker(threadPool* pool);
    void kernel();    
};
class threadPool{
    public:
    size_t threadCount;
    bool dispatchStart=false;
    std::condition_variable dispatchCV;
    std::condition_variable doneCV;
    std::mutex dispatch;
    std::mutex done;
    bool executing=false;
    bool stop=false;
    size_t workersFinished=0;
    threadPool();
    ~threadPool();
     std::array<int_fast8_t,144>* target;
    std::vector<worker> pool;
    size_t workloadSize;
    size_t workloadLastSize;
    void runStepThreaded(std::array<int_fast8_t,144> &target);
    void workerDone();

};
static std::array<int_fast8_t, 256> boardPadded;
constexpr int getPaddedIndex(int index);
inline int_fast8_t getTile(int pos);
inline bool matchMatrix(int pos,const rule &r);
int_fast8_t evaluateTile(int xpos,int ypos,std::array<int_fast8_t,144> &target);
class Automata : public Node2D {
    GDCLASS(Automata, Node2D)

private:
    double time_passed;

   
    
protected:
    static void _bind_methods();

public:
    threadPool pool=threadPool();
    void printRules();
    void stats();
    void clearRuleset();
    void addRule(Array Rules,int result);
    void compileRuleset();
    void removeDuplicateRules();
    rule rotate(rule& r);
    std::vector<rule> getRules();

    void runStep(std::array<int_fast8_t,144> &target);
    Array AutomataStep(Array board);
    godot::PackedByteArray simulateAutomataStepAndReturnActions(godot::PackedByteArray board,Array changes);
    godot::PackedByteArray AutomataStepPackedByte(godot::PackedByteArray board);



    Automata();
    ~Automata();

    
    void _process(double delta) override;
};


}



#endif
