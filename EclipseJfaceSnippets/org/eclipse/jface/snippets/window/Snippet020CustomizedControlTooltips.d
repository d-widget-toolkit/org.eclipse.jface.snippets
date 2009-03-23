/*******************************************************************************
 * Copyright (c) 2006 Tom Schindl and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Tom Schindl - initial API and implementation
 *******************************************************************************/

module dwtx.jface.snippets.window.Snippet020CustomizedControlTooltips;


import dwtx.jface.resource.ImageDescriptor;
import dwtx.jface.resource.JFaceResources;
import dwtx.jface.util.Policy;
import dwtx.jface.window.DefaultToolTip;
import dwtx.jface.window.ToolTip;
import dwt.DWT;
import dwt.events.MouseAdapter;
import dwt.events.MouseEvent;
import dwt.events.SelectionAdapter;
import dwt.events.SelectionEvent;
import dwt.events.SelectionListener;
import dwt.graphics.Point;
import dwt.graphics.RGB;
import dwt.layout.FillLayout;
import dwt.layout.GridData;
import dwt.layout.GridLayout;
import dwt.layout.RowLayout;
import dwt.widgets.Button;
import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Label;
import dwt.widgets.Link;
import dwt.widgets.MessageBox;
import dwt.widgets.Shell;
import dwt.widgets.Text;

import dwt.dwthelper.utils;
version(JIVE) import jive.stacktrace;

/**
 * Demonstrate usage of custom toolstips for controls
 *
 * @author Tom Schindl
 *
 */
public class Snippet020CustomizedControlTooltips {
    protected class MyToolTip : ToolTip {

        private Shell parentShell;

        private String headerText = "ToolTip-Header";

        public static const String HEADER_BG_COLOR = Policy.JFACE ~ ".TOOLTIP_HEAD_BG_COLOR";

        public static const String HEADER_FG_COLOR = Policy.JFACE ~ ".TOOLTIP_HEAD_FG_COLOR";

        public static const String HEADER_FONT = Policy.JFACE ~ ".TOOLTIP_HEAD_FONT";

        public static const String HEADER_CLOSE_ICON = Policy.JFACE ~ ".TOOLTIP_CLOSE_ICON";
        public static const String HEADER_HELP_ICON = Policy.JFACE ~ ".TOOLTIP_HELP_ICON";

        public this(Control control) {
            super(control);
            this.parentShell = control.getShell();
        }

        protected Composite createToolTipContentArea(Event event,
                Composite parent) {
            Composite comp = new Composite(parent,DWT.NONE);

            GridLayout gl = new GridLayout(1,false);
            gl.marginBottom=0;
            gl.marginTop=0;
            gl.marginHeight=0;
            gl.marginWidth=0;
            gl.marginLeft=0;
            gl.marginRight=0;
            gl.verticalSpacing=1;
            comp.setLayout(gl);

            Composite topArea = new Composite(comp,DWT.NONE);
            GridData data = new GridData(DWT.FILL,DWT.FILL,true,false);
            data.widthHint=200;
            topArea.setLayoutData(data);
            topArea.setBackground(JFaceResources.getColorRegistry().get(HEADER_BG_COLOR));

            gl = new GridLayout(2,false);
            gl.marginBottom=2;
            gl.marginTop=2;
            gl.marginHeight=0;
            gl.marginWidth=0;
            gl.marginLeft=5;
            gl.marginRight=2;

            topArea.setLayout(gl);

            Label l = new Label(topArea,DWT.NONE);
            l.setText(headerText);
            l.setBackground(JFaceResources.getColorRegistry().get(HEADER_BG_COLOR));
            l.setFont(JFaceResources.getFontRegistry().get(HEADER_FONT));
            l.setForeground(JFaceResources.getColorRegistry().get(HEADER_FG_COLOR));
            l.setLayoutData(new GridData(GridData.FILL_BOTH));

            Composite iconComp = new Composite(topArea,DWT.NONE);
            iconComp.setLayoutData(new GridData());
            iconComp.setLayout(new GridLayout(2,false));
            iconComp.setBackground(JFaceResources.getColorRegistry().get(HEADER_BG_COLOR));

            gl = new GridLayout(2,false);
            gl.marginBottom=0;
            gl.marginTop=0;
            gl.marginHeight=0;
            gl.marginWidth=0;
            gl.marginLeft=0;
            gl.marginRight=0;
            iconComp.setLayout(gl);

            Label helpIcon = new Label(iconComp,DWT.NONE);
            helpIcon.setBackground(JFaceResources.getColorRegistry().get(HEADER_BG_COLOR));
            helpIcon.setImage(JFaceResources.getImage(HEADER_HELP_ICON));
            helpIcon.addMouseListener(new class MouseAdapter {

                public void mouseDown(MouseEvent e) {
                    hide();
                    openHelp();
                }
            });


            Label closeIcon = new Label(iconComp,DWT.NONE);
            closeIcon.setBackground(JFaceResources.getColorRegistry().get(HEADER_BG_COLOR));
            closeIcon.setImage(JFaceResources.getImage(HEADER_CLOSE_ICON));
            closeIcon.addMouseListener(new class MouseAdapter {

                public void mouseDown(MouseEvent e) {
                    parentShell.setFocus();
                    hide();
                }
            });

            createContentArea(comp).setLayoutData(new GridData(GridData.FILL_BOTH));

            return comp;
        }

        protected Composite createContentArea(Composite parent) {
            return new Composite(parent,DWT.NONE);
        }

        protected void openHelp() {
            parentShell.setFocus();
        }
    }

    class MyToolTip2 : MyToolTip {
        public this(Control control) {
            super(control);
        }
        protected Composite createContentArea(Composite parent) {
            Composite comp = super.createContentArea(parent);
            comp.setBackground(parent.getDisplay().getSystemColor(DWT.COLOR_INFO_BACKGROUND));
            FillLayout layout = new FillLayout();
            layout.marginWidth=5;
            comp.setLayout(layout);
            Link l = new Link(comp,DWT.NONE);
            l.setText("This a custom tooltip you can: \n- pop up any control you want\n- define delays\n - ... \nGo and get Eclipse M4 from <a>http://www.eclipse.org</a>");
            l.setBackground(parent.getDisplay().getSystemColor(DWT.COLOR_INFO_BACKGROUND));
            l.addSelectionListener(new class SelectionAdapter {
                public void widgetSelected(SelectionEvent e) {
                    openURL();
                }
            });
            return comp;
        }

        protected void openURL() {
            MessageBox box = new MessageBox(parent,DWT.ICON_INFORMATION);
            box.setText("Eclipse.org");
            box.setMessage("Here is where we'd open the URL.");
            box.open();
        }

        protected void openHelp() {
            MessageBox box = new MessageBox(parent,DWT.ICON_INFORMATION);
            box.setText("Info");
            box.setMessage("Here is where we'd show some information.");
            box.open();
        }

    };
    Shell parent;
        DefaultToolTip toolTipDelayed;

    public this(Shell parent_) {
        this.parent = parent_;
        JFaceResources.getColorRegistry().put(MyToolTip.HEADER_BG_COLOR, new RGB(255,255,255));
        JFaceResources.getFontRegistry().put(MyToolTip.HEADER_FONT, JFaceResources.getFontRegistry().getBold(JFaceResources.getDefaultFont().getFontData()[0].getName()).getFontData());


        JFaceResources.getImageRegistry().put(MyToolTip.HEADER_CLOSE_ICON,ImageDescriptor.createFromFile(getImportData!("jface.snippets.showerr_tsk.gif")));
        JFaceResources.getImageRegistry().put(MyToolTip.HEADER_HELP_ICON,ImageDescriptor.createFromFile(getImportData!("jface.snippets.linkto_help.gif")));

        Text text = new Text(parent,DWT.BORDER);
        text.setText("Hello World");

        MyToolTip myTooltipLabel = new MyToolTip2(text);
        myTooltipLabel.setShift(new Point(-5, -5));
        myTooltipLabel.setHideOnMouseDown(false);
        myTooltipLabel.activate();

        text = new Text(parent,DWT.BORDER);
        text.setText("Hello World");
        DefaultToolTip toolTip = new DefaultToolTip(text);
        toolTip.setText("Hello World\nHello World");
        toolTip.setBackgroundColor(parent.getDisplay().getSystemColor(DWT.COLOR_RED));

        Button b = new Button(parent,DWT.PUSH);
        b.setText("Popup on press");

        toolTipDelayed = new DefaultToolTip(b,ToolTip.RECREATE,true);
        toolTipDelayed.setText("Hello World\nHello World");
        toolTipDelayed.setBackgroundColor(parent.getDisplay().getSystemColor(DWT.COLOR_RED));
        toolTipDelayed.setHideDelay(2000);

        b.addSelectionListener(new class SelectionAdapter {
            public void widgetSelected(SelectionEvent e) {
                toolTipDelayed.show(new Point(0,0));
            }
        });


    }

    public static void main(String[] args) {
        Display display = new Display();

        Shell shell = new Shell(display);
        shell.setLayout(new RowLayout());
        new Snippet020CustomizedControlTooltips(shell);

        shell.open();

        while (!shell.isDisposed()) {
            if (!display.readAndDispatch())
                display.sleep();
        }

        display.dispose();
    }
}

void main(){
    Snippet020CustomizedControlTooltips.main(null);
}

