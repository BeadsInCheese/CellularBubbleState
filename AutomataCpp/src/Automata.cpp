#include "Automata.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void Automata::_bind_methods() {
    
    ClassDB::bind_method(D_METHOD("AutomataStep", "board"),&Automata::AutomataStep);
    ClassDB::bind_method(D_METHOD("AutomataStepPackedByte", "board"),&Automata::AutomataStepPackedByte);
    ClassDB::bind_method(D_METHOD("simulateAutomataStepAndReturnActions", "board", "changes"),&Automata::simulateAutomataStepAndReturnActions);
    ClassDB::bind_method(D_METHOD("printRules"),&Automata::printRules);

    ClassDB::bind_method(D_METHOD("clearRuleset"),&Automata::clearRuleset);
    ClassDB::bind_method(D_METHOD("addRule","pattern","result"),&Automata::addRule);
    ClassDB::bind_method(D_METHOD("compileRuleset"),&Automata::compileRuleset);
    ClassDB::bind_method(D_METHOD("stats"),&Automata::stats);







}
std::vector<rule> rules;


Automata::~Automata() {
    // Cleanup code.
}
void godot::Automata::clearRuleset()
{
    rules.clear();
}
void godot::Automata::addRule(Array r,int result)
{
    if(r.size()!=3*3&&r.size()!=5*5){
        print_error("Error matrix must be eather size 3 or size 5");
        return;
    }
    rule rul;
    rul.matrixSize=sqrt(r.size());
    for(int i=0; i<r.size(); i++){
        if(r[i].get_type() == godot::Variant::Type::INT){
            rul.rows[i]=r[i];
        }else{
            print_error("Error incompatible matrix parameter "+r[i].get_type());
        return;
        }

    }
    rul.result=result;
    rules.push_back(rul);


}
void godot::Automata::compileRuleset()
{
    int rl=rules.size();
    for (int j=0; j<rl;j++){
        rule nr;
        bool changed=false;
        for(int k=0; k<rules[j].matrixSize*rules[j].matrixSize; k++){
            auto x=rules[j].rows[k];
            if(x==2){

                nr.rows[k]=4;
                changed=true;
            }
            else if(x==1){
                changed=true;
                nr.rows[k]=3;
            }
            else if(x==3){
                changed=true;
                nr.rows[k]=1;
            }
            else if(x==4){
                changed=true;
                nr.rows[k]=2;
            }else{
                nr.rows[k]=x;
            }
           
        }
        nr.result=rules[j].result;
        if(rules[j].result==1){
            nr.result=3;
        }
        else if(rules[j].result==2){
            nr.result=4;
        }else if(rules[j].result==3){
            nr.result=1;
        }else if(rules[j].result==4){
            nr.result=2;
        }else{
            nr.result=rules[j].result;
        }
        
        if(changed){
            nr.matrixSize=rules[j].matrixSize;
            rules.push_back(nr);
        }
    }
    rl=rules.size();
    
    for (int j=0; j<rl;j++){ 
        rule rot=rules[j];
        for(int i=0; i<4;i++){
            rot=rotate(rot);
            rules.push_back(rot);

        }
    }
    removeDuplicateRules();
    
}

void godot::Automata::removeDuplicateRules()
{

    std::unordered_map<rule,rule> table;

    for(int i=0; i< rules.size(); i++){
        print_line(rules[i].hash());
        table[rules[i]]=rules[i];
    }
    rules.clear();
    for(auto& i:table){
        rules.push_back(i.second);
    }


}

rule Automata::rotate(rule &r)
{
    rule rotated; 
    rotated.matrixSize=r.matrixSize;
        if(r.matrixSize==3){
             // Perform a 90-degree clockwise rotation:
            rotated.rows[0] = r.rows[6];
            rotated.rows[1] = r.rows[3];
            rotated.rows[2] = r.rows[0];
            
            rotated.rows[3] = r.rows[7];
            rotated.rows[4] = r.rows[4]; // Center remains the same
            rotated.rows[5] = r.rows[1];
            
            rotated.rows[6] = r.rows[8];
            rotated.rows[7] = r.rows[5];
            rotated.rows[8] = r.rows[2];
            
            rotated.result = r.result;
    
        
    }
    else{

        rotated.rows[0] = r.rows[20];
        rotated.rows[1] = r.rows[15];
        rotated.rows[2] = r.rows[10]; 
        rotated.rows[3] = r.rows[5];
        rotated.rows[4] = r.rows[0]; 
        rotated.rows[5] = r.rows[21];
            
        rotated.rows[6] = r.rows[16];
        rotated.rows[7] = r.rows[11];
        rotated.rows[8] = r.rows[6];
            
        rotated.rows[9] = r.rows[1];
        rotated.rows[10] = r.rows[22];
        rotated.rows[11] = r.rows[17];
            
        rotated.rows[12] = r.rows[12];
        rotated.rows[13] = r.rows[7]; 
        rotated.rows[14] = r.rows[2];
            
        rotated.rows[15] = r.rows[23];
        rotated.rows[16] = r.rows[18];
        rotated.rows[17] = r.rows[13];
            
        rotated.rows[18] = r.rows[8];
        rotated.rows[19] = r.rows[3];
        rotated.rows[20] = r.rows[24];
            
        rotated.rows[21] = r.rows[19];
        rotated.rows[22] = r.rows[14]; 
        rotated.rows[23] = r.rows[9];  
        rotated.rows[24] = r.rows[4];

        rotated.result = r.result;

    }
    return rotated;
}

void Automata::printRules(){
    UtilityFunctions::print(" rulecount "+String::num(rules.size()));
    for(int i=0;i<rules.size(); i++){
        UtilityFunctions::print("Rule: ");
        for(int j=0;j<rules[i].matrixSize; j++){
            String text="";
            for(int k=0;k<rules[i].matrixSize; k++){
               text+= String::num(rules[i].rows[j*rules[i].matrixSize+k])+" , ";
            }  
            UtilityFunctions::print(text);
        }

        UtilityFunctions::print("Result: "+String::num(rules[i].result));
    }

}

void godot::Automata::stats()
{
    auto A = std::array<int_fast8_t,144>();
    auto B = std::array<int_fast8_t,144>();

    auto t1 = std::chrono::high_resolution_clock::now();
    runStep(A, B);
    auto t2 = std::chrono::high_resolution_clock::now();

    std::chrono::duration<double, std::milli> ms_double = t2 - t1;
    print_line("singlethread step " + String::num(ms_double.count()) + " ms");

    t1 = std::chrono::high_resolution_clock::now();
    pool.runStepThreaded(A, B);
    t2 = std::chrono::high_resolution_clock::now();

    ms_double = t2 - t1;
    print_line("threaded step " + String::num(ms_double.count()) + " ms");


    t1 = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < 100000; i++) {
        runStep(A, B);
    }
    t2 = std::chrono::high_resolution_clock::now();

    ms_double = t2 - t1;
    print_line("singlethread step x100000 " + String::num(ms_double.count()) + " ms");


    t1 = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < 100000; i++) {
        pool.runStepThreaded(A, B);
    }
    t2 = std::chrono::high_resolution_clock::now();

    ms_double = t2 - t1;
    print_line("threaded step x100000 " + String::num(ms_double.count()) + " ms");
}


std::vector<rule> Automata::getRules()
{
    std::vector<rule> rules;

    rule r;
    r.rows={-1,2,-1,
            2,4,-1,
            -1,-1,-1};
    r.result=2;
    rules.push_back(r);
    rule r2;
    r2.rows={2,2,2,
            -1,0,-1,
            -1,-1,-1};
    r2.result=2;
    rules.push_back(r2);
    
    rule r3;
    r3.rows={-1,-1,-1,
            -1,0,1,
            -1,1,2};
    r3.result=2;
    rules.push_back(r3);

    rule r4;
    r4.rows={-1,1,-1,
            -1,0,-1,
            -1,1,-1};
    r4.result=2;
    rules.push_back(r4);

    
    rule r5;
    r5.rows={-1,-1,-1,
            -1,0,2,
            -1,1,2};
    r5.result=2;
    rules.push_back(r5);

    rule r6;
    r6.rows={-1,-1,-1,
            0,2,-1,
            1,2,-1};
    r6.result=0;
    rules.push_back(r6);
    rule r7;
    r7.rows={-1,-1,-1,
            2,0,-1,
            2,1,-1};
    r7.result=2;
    rules.push_back(r7);

    rule r8;
    r8.rows={-1,-1,-1,
            -1,2,0,
            -1,2,1};
    r8.result=0;
    rules.push_back(r8);

    rule r9;
    r9.rows={
            -1,-1,-1,-1,-1,
            -1,-1,-1,-1,-1,
            1,2,0,-1,-1,
            -1,-1,-1,-1,-1,
            -1,-1,-1,-1,-1
        }
        ;
        r9.matrixSize=5;
    r9.result=2;
    
    rules.push_back(r9);

    rule r10;
    r10.rows={
            -1,-1,-1,-1,-1,
            -1,-1,-1,-1,-1,
            1,0,1,-1,-1,
            -1,-1,-1,-1,-1,
            -1,-1,-1,-1,-1
        }
        ;
        r10.matrixSize=5;
    r10.result=0;
    
    rules.push_back(r10);

    int rl=rules.size();
    for (int j=0; j<rl;j++){
        rule nr;
        bool changed=false;
        for(int k=0; k<25; k++){
            auto x=rules[j].rows[k];
            if(x==2){

                nr.rows[k]=4;
                changed=true;
            }
            else if(x==1){
                changed=true;
                nr.rows[k]=3;
            }
            else if(x==3){
                changed=true;
                nr.rows[k]=1;
            }
            else if(x==4){
                changed=true;
                nr.rows[k]=2;
            }else{
                nr.rows[k]=x;
            }
           
        }
        nr.result=rules[j].result;
        if(rules[j].result==1){
            nr.result=3;
        }
        else if(rules[j].result==2){
            nr.result=4;
        }else if(rules[j].result==3){
            nr.result=1;
        }else if(rules[j].result==4){
            nr.result=2;
        }else{
            nr.result=rules[j].result;
        }
        
        if(changed){
            nr.matrixSize=rules[j].matrixSize;
            rules.push_back(nr);
        }
    }
    rl=rules.size();
    
    for (int j=0; j<rl;j++){ 
        rule rot=rules[j];
        for(int i=0; i<4;i++){
            rot=rotate(rot);
            rules.push_back(rot);

        }
    }
    return rules;
}
Automata::Automata() {
    auto r=getRules();
    UtilityFunctions::print("Automata rules initiated rulecount "+String::num(r.size()));
    rules=r;
}
inline int_fast8_t godot::getTile(int xpos,int ypos,int xsize,int ysize,const std::array<int_fast8_t,144> &board){
    if (xpos < 0 || ypos < 0 || xpos >= xsize || ypos >= ysize) {
        return 5;
    }
    return board[xpos + ypos * ysize];
}

inline bool godot::matchMatrix(int posx, int posy,const std::array<int_fast8_t, 144> &board,const rule &r){
     int div=(r.matrixSize/2);
    for(int i=0; i<r.matrixSize;i++){
        for(int j=0; j<r.matrixSize;j++){
           
            int a=r.rows[i+j*r.matrixSize];
            int b=getTile(posx-(div)+i,posy+j-(div),12,12,board);
            
            if(a==-1){
                continue;
            }
            if(b!=a){
                return false;
            }
            
        }
        
        
    }
    return true;
    

}
int_fast8_t godot::evaluateTile(int xpos, int ypos,const std::array<int_fast8_t, 144> &board,  std::array<int_fast8_t,144> &target)
{
    for (const rule& i:rules)
    {
        if (matchMatrix(xpos, ypos, board, i))[[unlikely]]
        {
            target[xpos + ypos * 12] = i.result;
            break;
        }
        
    }

    

    return 0;
}
void Automata::runStep(const std::array<int_fast8_t,144> &board,std::array<int_fast8_t,144> &target ){
    for(int i=0; i< board.size(); i++){
        int x=i%12;
        int y=i/12;

        evaluateTile(x,y,board,target);
    }

}
static std::mutex automata_mutex;
Array Automata::AutomataStep(Array board){
    std::lock_guard<std::mutex> lock(automata_mutex);
    std::array<int_fast8_t, 144> b;
    for(int i=0; i<144; i++){
        b[i]=int(board[i]);

    }
    std::array<int_fast8_t, 144> target;
    memcpy(target.data(),b.data(),b.size()*sizeof(int_fast8_t));
    pool.runStepThreaded(b,target);
    //runStep(b,target);
    for(int i=0; i<144; i++){
        board[i]=int(target[i]);

    }
    return board;

}
godot::PackedByteArray godot::Automata::simulateAutomataStepAndReturnActions(godot::PackedByteArray board,Array changes)
{
    std::lock_guard<std::mutex> lock(automata_mutex);
    std::array<int_fast8_t, 144> b;
    memcpy(b.data(),board.ptr(),b.size()*sizeof(int_fast8_t));
    std::array<int_fast8_t, 144> target;
    memcpy(target.data(),b.data(),b.size()*sizeof(int_fast8_t));


    
    pool.runStepThreaded(b,target);
    memcpy(board.ptrw(),target.data(),target.size()*sizeof(int_fast8_t));
    
    for(int i=0; i<144; i++){
        if(b[i]!=target[i]){
            godot::Array entry;
            entry.resize(3);
            entry[0]=i;
            entry[2]=b[i];
            entry[1]=target[i];
            changes.append(entry);

        }
    }

    return board;
}
godot::PackedByteArray Automata::AutomataStepPackedByte(godot::PackedByteArray board)
{
    std::lock_guard<std::mutex> lock(automata_mutex);
    std::array<int_fast8_t, 144> b;
    memcpy(b.data(),board.ptr(),b.size()*sizeof(int_fast8_t));
    std::array<int_fast8_t, 144> target;
    memcpy(target.data(),b.data(),b.size()*sizeof(int_fast8_t));
    pool.runStepThreaded(b,target);
    memcpy(board.ptrw(),target.data(),target.size()*sizeof(int_fast8_t));
    return board;
}

void Automata::_process(double delta) {
}

unsigned int rule::hash()const
{
    unsigned int h=0;
    for(int i=0; i<matrixSize; i++){
        h+=unsafePow(6,i)*(rows[i]+2);
    }
    return h;
}
int unsafePow(unsigned int a,unsigned int b){
    if(b==0){
        return 1;
    }
    if(b%2==1){
        return a*unsafePow(a,b-1);
    }
    int half=b/2;
    return unsafePow(a,half)*unsafePow(a,half);

}

bool operator==(const rule& a, const rule& b) {
    if (a.matrixSize != b.matrixSize) return false;
    for (int i = 0; i < a.matrixSize * a.matrixSize; i++) {
        if (a.rows[i] != b.rows[i]) return false;
    }
    return true;
}

void arena::push_back(rule element)
{
    ruleArray[ptr]=element;
    ptr++;
}

void arena::clear()
{
    ptr=0;
}

size_t arena::size()
{
    return ptr;
}

void worker::kernel()
{
        while(true){
            std::unique_lock<std::mutex> lk(pool->dispatch); 
            pool->dispatchCV.wait(lk, [&]{ return (pool->dispatchStart&&!executing) || pool->stop; });
            if (pool->stop) return;
            executing=true;
            lk.unlock();

                for(int i=wrk.start;i<wrk.end;i++){
                    
                    evaluateTile(i%12,i/12,*pool->board,*pool->target);
                  //  print_line(i,"  ",wrk.start,"-",wrk.end);
                }
            pool->workerDone();
        }


    }
godot::worker::worker(threadPool* pool):workerThread(&worker::kernel,this), pool(pool){}
    godot::threadPool::threadPool()
    {
        threadCount=std::max((int)std::thread::hardware_concurrency(),1);
        pool.reserve(threadCount);
        workloadSize=144/threadCount;
        workloadLastSize=144%threadCount;
        for(int i=0;i<threadCount;i++){
            pool.emplace_back(this);
            pool[i].wrk.start=i*workloadSize+std::min(i,(int)workloadLastSize);
            pool[i].wrk.end=pool[i].wrk.start+(i<workloadLastSize? 1+workloadSize:workloadSize);
        }

    }

    godot::threadPool::~threadPool(){ 
    { 
        std::lock_guard<std::mutex> lk(dispatch); 
        stop = true; 
        doneCV.notify_all();

    } 
    dispatchCV.notify_all();  
    for (auto& w : pool) { 
        if (w.workerThread.joinable()) {
            w.workerThread.join();

        }
            
    } 
}
static std::mutex call;
    void godot::threadPool::runStepThreaded(const std::array<int_fast8_t,144> &board,std::array<int_fast8_t,144> &target)
    {
        std::lock_guard<std::mutex> guard(call);
        for(auto& i : pool){
            i.executing=false;
        }
       { 
        std::lock_guard<std::mutex> guard(done);
        workersFinished = 0; 
        }
        { 
            std::lock_guard<std::mutex> lk(dispatch);        
            this->board=&board;
            this->target=&target;

            
 
            dispatchStart = true; 
        }
        dispatchCV.notify_all();
        executing=true;
        std::unique_lock<std::mutex> lock(done);
        doneCV.wait(lock, [&]{ return workersFinished >= threadCount; });
        {
            std::lock_guard<std::mutex> lk(dispatch);
            dispatchStart = false;
        }
        executing=false;

    }

    void godot::threadPool::workerDone()
    {
        {
            std::lock_guard<std::mutex> guard(done);
            workersFinished+=1;
            
        }
        doneCV.notify_one();
    }
