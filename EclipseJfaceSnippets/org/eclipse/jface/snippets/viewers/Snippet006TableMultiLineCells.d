/*******************************************************************************
* Copyright (c) 2005, 2007 IBM Corporation and others.
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*
* Contributors:
*     IBM Corporation - initial API and implementation
* Port to the D programming language:
*     yidabu at gmail dot com  ( D China http://www.d-programming-language-china.org/ )
*******************************************************************************/
module org.eclipse.jface.snippets.viewers.Snippet006TableMultiLineCells;


// http://dev.eclipse.org/viewcvs/index.cgi/org.eclipse.jface.snippets/Eclipse%20JFace%20Snippets/org/eclipse/jface/snippets/viewers/Snippet006TableMultiLineCells.java?view=markup

import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.jface.viewers.ColumnPixelData;
import org.eclipse.jface.viewers.IStructuredContentProvider;
import org.eclipse.jface.viewers.OwnerDrawLabelProvider;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.jface.viewers.TableLayout;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.TableViewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.TableColumn;

import java.lang.all;
version(JIVE){
    import jive.stacktrace;
}

void main(String[] args) {
    (new Snippet006TableMultiLineCells()).main(args);
}

public class Snippet006TableMultiLineCells {

    public static void main(String[] args) {

        Display display = new Display();
        Shell shell = new Shell(display, SWT.CLOSE|SWT.RESIZE);
        shell.setSize(400, 400);
        shell.setLayout(new GridLayout());

        Snippet006TableMultiLineCells example = new Snippet006TableMultiLineCells();
        example.createPartControl(shell);

        shell.open();

        while (!shell.isDisposed()) {
            if (!display.readAndDispatch())
                display.sleep();
        }
        display.dispose();
    }

    class LineEntry {

        String line;
        int columnWidth;

        /**
         * Create a new instance of the receiver with name text constrained to a
         * column of width.
         *
         * @param text
         * @param width
         */
        this(String text, int width) {
            line = text;
            columnWidth = width;
        }

        /**
         * Get the height of the event.
         *
         * @param index
         * @return int
         */
        public int getHeight(Event event) {
            event.gc.setLineWidth(columnWidth);
            return event.gc.textExtent(line).y;
        }

        /**
         * Get the width of the event.
         *
         * @param index
         * @return
         */
        public int getWidth(Event event) {

            return columnWidth;
        }

        /**
         * Get the font we are using.
         *
         * @return Font
         */
        protected Font getFont() {
            return JFaceResources.getFont(JFaceResources.HEADER_FONT);
        }

        /**
         * @param event
         */
        public void draw(Event event) {
            event.gc.drawText(line, event.x, event.y);

        }
    }

    private TableViewer viewer;

    private LineEntry[] entries;

    public this() {
        String[] lines = [
            "This day is called the feast of Crispian:",
            "He that outlives this day, \n and comes safe home,",
            "Will stand a tip-toe when the day is named,",
            "And rouse him at the name of Crispian.",
            "He that shall live this day,\n and see old age,",
            "Will yearly on the vigil feast his neighbours,",
            "And say 'To-morrow is Saint Crispian:'",
            "Then will he strip his sleeve and show his scars.",
            "And say 'These wounds I had on Crispin's day.'",
            "Old men forget:\n yet all shall be forgot,",
            "But he'll remember with advantages",
            "What feats he did that day:\n then shall our names.",
            "Familiar in his mouth as household words",
            "Harry the king, Bedford and Exeter,",
            "Warwick and Talbot,\n Salisbury and Gloucester,",
            "Be in their flowing cups freshly remember'd.",
            "This story shall the good man teach his son;",
            "And Crispin Crispian shall ne'er go by,",
            "From this day to the ending of the world,",
            "But we in it shall be remember'd;",
            "We few,\n we happy few,\n we band of brothers;",
            "For he to-day that sheds his blood with me",
            "Shall be my brother;\n be he ne'er so vile,",
            "This day shall gentle his condition:",
            "And gentlemen in England now a-bed",
            "Shall think themselves accursed they were not here,",
            "And hold their manhoods cheap whiles any speaks",
            "That fought with us upon Saint Crispin's day." ];

        entries = new LineEntry[lines.length];
        for (int i = 0; i < lines.length; i++) {
            entries[i] = new LineEntry(lines[i], 35);
        }
    }

    /*
     * (non-Javadoc)
     *
     * @see org.eclipse.ui.part.WorkbenchPart#createPartControl(org.eclipse.swt.widgets.Composite)
     */
    public void createPartControl(Composite parent) {
        viewer = new TableViewer(parent, SWT.FULL_SELECTION);

        viewer.setContentProvider(new class() IStructuredContentProvider {
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
             * @see org.eclipse.jface.viewers.IStructuredContentProvider#getElements(java.lang.Object)
             */
            public Object[] getElements(Object inputElement) {
                return entries;
            }

            /*
             * (non-Javadoc)
             *
             * @see org.eclipse.jface.viewers.IContentProvider#inputChanged(org.eclipse.jface.viewers.Viewer,
             *      java.lang.Object, java.lang.Object)
             */
            public void inputChanged(org.eclipse.jface.viewers.Viewer.Viewer viewer, Object oldInput, Object newInput) {
            }
        });
        createColumns();

        viewer.setLabelProvider(new class OwnerDrawLabelProvider {
            /* (non-Javadoc)
             * @see org.eclipse.jface.viewers.OwnerDrawLabelProvider#measure(org.eclipse.swt.widgets.Event, java.lang.Object)
             */
            protected void measure(Event event, Object element) {
                LineEntry line = cast(LineEntry) element;
                Point size = event.gc.textExtent(line.line);
                event.width = viewer.getTable().getColumn(event.index).getWidth();
                int lines = (event.width > 0 ? (size.x / event.width + 1) : 1);
                event.height = size.y * lines;
            }

            /*
             * (non-Javadoc)
             *
             * @see org.eclipse.jface.viewers.OwnerDrawLabelProvider#paint(org.eclipse.swt.widgets.Event,
             *      java.lang.Object)
             */
            protected void paint(Event event, Object element) {

                LineEntry entry = cast(LineEntry) element;
                event.gc.drawText(entry.line, event.x, event.y, true);
            }
        });
        viewer.setInput(this);

        GridData data = new GridData(GridData.GRAB_HORIZONTAL
                | GridData.GRAB_VERTICAL | GridData.FILL_BOTH);

        viewer.getControl().setLayoutData(data);
        OwnerDrawLabelProvider.setUpOwnerDraw(viewer);

        viewer.setSelection(new StructuredSelection(entries[1]));
    }

    /**
     * Create the columns to be used in the tree.
     */
    private void createColumns() {
        TableLayout layout = new TableLayout();
        viewer.getTable().setLayout(layout);
        viewer.getTable().setHeaderVisible(true);
        viewer.getTable().setLinesVisible(true);

        TableColumn tc = new TableColumn(viewer.getTable(), SWT.NONE, 0);
        layout.addColumnData(new ColumnPixelData(350));
        tc.setText("Lines");

    }

    public void setFocus() {
    }
}

