OBJECTS=Main.o
AS=/usr/bin/as
LDFLAGS=-g
EXECUTABLES=ants

all: ants

ants: $(OBJECTS)
	g++ $(LDFLAGS) -o ants $^

clean:
	-rm -rf *.o $(EXECUTABLES)

.PHONY: clean
