class _qinput:
    """Take care of the changes in inputs between Python 2 and 3, as well as enabling a getch-like functionality"""
    def __init__(self):
        try:
            import yn
        except ImportError:
            print("This package requires the module 'yn' to function. Please make sure it's in the load path or the same directory as this file.")
            return None

    def yn(self,string):
        import yn
        return yn.yn(string)

    def input(self,string):
        try:
            return raw_input(string)
        except NameError:
            return input(string)
