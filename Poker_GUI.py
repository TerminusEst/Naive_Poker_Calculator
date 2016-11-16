import wx

from SCORE import SCOREpyx 	# IMPORTANT
from SCORE import flopodds 	# IMPORTANT
from SCORE import turnodds	# IMPORTANT
from SCORE import riverodds	# IMPORTANT
from SCORE import randflopodds
from SCORE import randpreflopodds


class ExampleFrame(wx.Frame):
    def __init__(self, parent, title):
        wx.Frame.__init__(self, parent, title=title)

        self.panel = wx.Panel(self)     

        self.hand = wx.StaticText(self.panel, label="Your cards:")
        self.handinsert = wx.TextCtrl(self.panel, size=(140, -1))

        self.flop = wx.StaticText(self.panel, label = "Flop:")
        self.flopinsert = wx.TextCtrl(self.panel, size=(140, -1))

        self.turn = wx.StaticText(self.panel, label = "Turn:")
        self.turninsert = wx.TextCtrl(self.panel, size=(140, -1))

        self.river = wx.StaticText(self.panel, label = "River:")
        self.riverinsert = wx.TextCtrl(self.panel, size=(140, -1))

        self.results = wx.StaticText(self.panel, label = "Results:")
        self.resultsblank1 = wx.StaticText(self.panel, label = "")
        self.resultsblank2 = wx.StaticText(self.panel, label = "")
        self.resultsblank3 = wx.StaticText(self.panel, label = "")

        self.results.SetForegroundColour(wx.RED)
        self.resultsblank1.SetForegroundColour(wx.RED)
        self.resultsblank2.SetForegroundColour(wx.RED)
        self.resultsblank3.SetForegroundColour(wx.RED)

        self.button = wx.Button(self.panel, label = 'Calculate')
        self.buttonclear = wx.Button(self.panel, label = 'Clear')

        # Set sizer for the frame, so we can change frame size to match widgets
        self.windowSizer = wx.BoxSizer()
        self.windowSizer.Add(self.panel, 1, wx.ALL | wx.EXPAND)        

        # Set sizer for the panel content
        self.sizer = wx.GridBagSizer(5, 20)

        self.sizer.Add(self.hand, (0, 0))
        self.sizer.Add(self.handinsert, (0, 3))

        self.sizer.Add(self.flop, (1, 0))
        self.sizer.Add(self.flopinsert, (1, 3))

        self.sizer.Add(self.turn, (2, 0))
        self.sizer.Add(self.turninsert, (2, 3))

        self.sizer.Add(self.river, (3, 0))
        self.sizer.Add(self.riverinsert, (3, 3))

        self.sizer.Add(self.results, (4, 0))
        self.sizer.Add(self.resultsblank1, (4, 3))
        self.sizer.Add(self.resultsblank2, (5, 3))
        self.sizer.Add(self.resultsblank3, (6, 3))


        self.sizer.Add(self.button, (7, 3), flag=wx.EXPAND)
        self.sizer.Add(self.buttonclear, (7, 0), flag=wx.EXPAND)

        # Set simple sizer for a nice border
        self.border = wx.BoxSizer()
        self.border.Add(self.sizer, 1, wx.ALL | wx.EXPAND, 5)

        # Use the sizers
        self.panel.SetSizerAndFit(self.border)  
        self.SetSizerAndFit(self.windowSizer)  

        # Set event handlers
        self.button.Bind(wx.EVT_BUTTON, self.Calculate)
        self.buttonclear.Bind(wx.EVT_BUTTON, self.ClearButton)

    def Calculate(self, e):
        if len(self.handinsert.GetValue()) == 0:
            self.resultsblank1.SetLabel("Enter Hole Cards!")
            return

        if len(self.flopinsert.GetValue()) == 0:    #preflop
            hand1, hand2 = str(self.handinsert.GetValue()[0:2]), str(self.handinsert.GetValue()[3:5])
            totalhand = [hand1, hand2]
            win, loss, draw = randpreflopodds(totalhand, 75000)

            self.resultsblank1.SetLabel("Win = {0:.2f}%".format(win*100))
            self.resultsblank2.SetLabel("Loss = {0:.2f}%".format(loss*100))
            self.resultsblank3.SetLabel("Draw = {0:.2f}%".format((1-(win + loss))*100))
            return

        if len(self.turninsert.GetValue()) == 0:   #flop
            hand1, hand2 = str(self.handinsert.GetValue()[0:2]), str(self.handinsert.GetValue()[3:5])
            flop1, flop2, flop3 = str(self.flopinsert.GetValue()[0:2]), str(self.flopinsert.GetValue()[3:5]), str(self.flopinsert.GetValue()[6:8])
            totalhand = [hand1, hand2, flop1, flop2, flop3]
            win, loss, draw = randflopodds(totalhand, 75000)

            self.resultsblank1.SetLabel("Win = {0:.2f}%".format(win*100))
            self.resultsblank2.SetLabel("Loss = {0:.2f}%".format(loss*100))
            self.resultsblank3.SetLabel("Draw = {0:.2f}%".format((1-(win + loss))*100))
            return           

        if len(self.riverinsert.GetValue()) == 0:   #turn
            hand1, hand2 = str(self.handinsert.GetValue()[0:2]), str(self.handinsert.GetValue()[3:5])
            flop1, flop2, flop3 = str(self.flopinsert.GetValue()[0:2]), str(self.flopinsert.GetValue()[3:5]), str(self.flopinsert.GetValue()[6:8])
            turn = str(self.turninsert.GetValue()[0:2])

            totalhand = [hand1, hand2, flop1, flop2, flop3, turn]
            win, loss, draw = turnodds(totalhand)

            self.resultsblank1.SetLabel("Win = {0:.2f}%".format(win*100))
            self.resultsblank2.SetLabel("Loss = {0:.2f}%".format(loss*100))
            self.resultsblank3.SetLabel("Draw = {0:.2f}%".format((1-(win + loss))*100))
            return 

        else:           # river
            hand1, hand2 = str(self.handinsert.GetValue()[0:2]), str(self.handinsert.GetValue()[3:5])
            flop1, flop2, flop3 = str(self.flopinsert.GetValue()[0:2]), str(self.flopinsert.GetValue()[3:5]), str(self.flopinsert.GetValue()[6:8])
            turn = str(self.turninsert.GetValue()[0:2])
            river = str(self.riverinsert.GetValue()[0:2])

            totalhand = [hand1, hand2, flop1, flop2, flop3, turn, river]
            win, loss, draw = riverodds(totalhand)

            self.resultsblank1.SetLabel("Win = {0:.2f}%".format(win*100))
            self.resultsblank2.SetLabel("Loss = {0:.2f}%".format(loss*100))
            self.resultsblank3.SetLabel("Draw = {0:.2f}%".format((1-(win + loss))*100))
            return 

    def ClearButton(self, e):
        self.handinsert.Clear()
        self.flopinsert.Clear()
        self.turninsert.Clear()
        self.riverinsert.Clear()
        self.resultsblank1.SetLabel("")
        self.resultsblank2.SetLabel("")
        self.resultsblank3.SetLabel("")




app = wx.App(False)
frame = ExampleFrame(None, title = "Blake's Poker Calculator")
frame.Show()
app.MainLoop()




