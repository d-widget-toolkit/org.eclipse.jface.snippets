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

module org.eclipse.jface.snippets.window.Snippet023TreeViewerCustomTooltips;

import org.eclipse.jface.viewers.CellLabelProvider;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.TreeItem;

import java.lang.all;
import java.util.ArrayList;

import tango.text.convert.Format;
import tango.util.log.Trace;

/**
 * A simple TreeViewer to demonstrate how custom tooltips could be created
 * easily. This is an extended version from
 * http://dev.eclipse.org/viewcvs/index.cgi/%7Echeckout%7E/org.eclipse.swt.snippets/src/org/eclipse/swt/snippets/Snippet125.java
 *
 * This code is for users pre 3.3 others could use newly added tooltip support in
 * {@link CellLabelProvider}
 *
 * @author Tom Schindl <tom.schindl@bestsolution.at>
 *
 */
public class Snippet023TreeViewerCustomTooltips {
    private class MyContentProvider : ITreeContentProvider {

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.IStructuredContentProvider#getElements(java.lang.Object)
         */
        public Object[] getElements(Object inputElement) {
            return (cast(MyModel) inputElement).child.toArray();
        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.IContentProvider#dispose()
         */
        public void dispose() {

        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.IContentProvider#inputChanged(org.eclipse.jface.viewers.Viewer,
         *      java.lang.Object, java.lang.Object)
         */
        public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {

        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.ITreeContentProvider#getChildren(java.lang.Object)
         */
        public Object[] getChildren(Object parentElement) {
            return getElements(parentElement);
        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.ITreeContentProvider#getParent(java.lang.Object)
         */
        public Object getParent(Object element) {
            if (element is null) {
                return null;
            }

            return (cast(MyModel) element).parent;
        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.ITreeContentProvider#hasChildren(java.lang.Object)
         */
        public bool hasChildren(Object element) {
            return (cast(MyModel) element).child.size() > 0;
        }

    }

    public class MyModel {
        public MyModel parent;

        public ArrayList child;

        public int counter;

        public this(int counter, MyModel parent) {
            this.parent = parent;
            this.counter = counter;
            child = new ArrayList();
        }

        public String toString() {
            return Format( "Item {}{}", (parent !is null) ? "." : "", counter );
        }
    }

    TreeViewer v;
    Listener labelListener;

    public this(Shell shell) {
        v = new TreeViewer(shell);
        v.setLabelProvider(new LabelProvider());
        v.setContentProvider(new MyContentProvider());
        v.setInput(createModel());
        v.getTree().setToolTipText("");

        labelListener = dgListener ( (Event event){
            Label label = cast(Label)event.widget;
            Shell shell_ = label.getShell ();
            switch (event.type) {
                case SWT.MouseDown:
                    Event e = new Event ();
                    e.item = cast(TreeItem) label.getData ("_TABLEITEM");
                    // Assuming table is single select, set the selection as if
                    // the mouse down event went through to the table
                    v.getTree().setSelection ([cast(TreeItem) e.item]);
                    v.getTree().notifyListeners (SWT.Selection, e);
                    shell_.dispose ();
                    v.getTree().setFocus();
                    break;
                case SWT.MouseExit:
                    shell_.dispose ();
                    break;
                default:
            }
        });

        Listener treeListener = new MyTreeListener();
        v.getTree().addListener (SWT.Dispose, treeListener);
        v.getTree().addListener (SWT.KeyDown, treeListener);
        v.getTree().addListener (SWT.MouseMove, treeListener);
        v.getTree().addListener (SWT.MouseHover, treeListener);
    }

    class MyTreeListener : Listener {
        Shell tip = null;
        Label label = null;
        public void handleEvent (Event event) {
            switch (event.type) {
                case SWT.Dispose:
                case SWT.KeyDown:
                case SWT.MouseMove: {
                    if (tip is null) break;
                    tip.dispose ();
                    tip = null;
                    label = null;
                    break;
                }
                case SWT.MouseHover: {
                    Point coords = new Point(event.x, event.y);
                    TreeItem item = v.getTree().getItem(coords);
                    if (item !is null) {
                        int columns = v.getTree().getColumnCount();

                        for (int i = 0; i < columns || i is 0; i++) {
                            if (item.getBounds(i).contains(coords)) {
                                if (tip !is null  && !tip.isDisposed ()) tip.dispose ();
                                tip = new Shell (v.getTree().getShell(), SWT.ON_TOP | SWT.NO_FOCUS | SWT.TOOL);
                                tip.setBackground (v.getTree().getDisplay().getSystemColor (SWT.COLOR_INFO_BACKGROUND));
                                FillLayout layout = new FillLayout ();
                                layout.marginWidth = 2;
                                tip.setLayout (layout);
                                label = new Label (tip, SWT.NONE);
                                label.setForeground (v.getTree().getDisplay().getSystemColor (SWT.COLOR_INFO_FOREGROUND));
                                label.setBackground (v.getTree().getDisplay().getSystemColor (SWT.COLOR_INFO_BACKGROUND));
                                label.setData ("_TABLEITEM", item);
                                label.setText (Format("Tooltip: {} => {}", item.getData(), i));
                                label.addListener (SWT.MouseExit, labelListener);
                                label.addListener (SWT.MouseDown, labelListener);
                                Point size = tip.computeSize (SWT.DEFAULT, SWT.DEFAULT);
                                Rectangle rect = item.getBounds (i);
                                Point pt = v.getTree().toDisplay (rect.x, rect.y);
                                tip.setBounds (pt.x, pt.y, size.x, size.y);
                                tip.setVisible (true);
                                break;
                            }
                        }
                    }
                }
                default:
            }
        }
    };

    private MyModel createModel() {

        MyModel root = new MyModel(0, null);
        root.counter = 0;

        MyModel tmp;
        for (int i = 1; i < 10; i++) {
            tmp = new MyModel(i, root);
            root.child.add(tmp);
            for (int j = 1; j < i; j++) {
                tmp.child.add(new MyModel(j, tmp));
            }
        }

        return root;
    }

    public static void main(String[] args) {
        Display display = new Display();
        Shell shell = new Shell(display);
        shell.setLayout(new FillLayout());
        new Snippet023TreeViewerCustomTooltips(shell);
        shell.open();

        while (!shell.isDisposed()) {
            if (!display.readAndDispatch())
                display.sleep();
        }

        display.dispose();
    }
}

void main(){
    Snippet023TreeViewerCustomTooltips.main(null);
}


