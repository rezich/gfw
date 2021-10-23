foo :: (num: int) -> int #must {
    return num + 4;
}

foo :: (num: int) {
    print("malarky\n");
}

main :: () {
    foo(42);
    bar := foo(108);
}

#import "Basic";