# Simple Python example
class DataProcessor:
    def __init__(self, data):
        self.data = data
        self.processed = False
    
    def process(self):
        # Process the data
        result = [x * 2 for x in self.data if x > 0]
        self.processed = True
        return result

def main():
    # Sample data
    data = [1, 5, -3, 10, 8, 0, -5]
    processor = DataProcessor(data)
    result = processor.process()
    print(f"Processed data: {result}")

if __name__ == "__main__":
    main()
# Updated on 2025-04-25 08:06:15 - Session: morning
# Updated on 2025-04-25 21:55:58 - Session: afternoon
