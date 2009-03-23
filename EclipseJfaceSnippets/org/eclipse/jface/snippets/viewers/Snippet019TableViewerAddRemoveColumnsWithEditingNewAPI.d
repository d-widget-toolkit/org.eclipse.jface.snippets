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

module org.eclipse.jface.snippets.viewers.Snippet019TableViewerAddRemoveColumnsWithEditingNewAPI;


import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IMenuListener;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.internal.ConfigureColumnsDialog;
import org.eclipse.jface.viewers.CellEditor;
import org.eclipse.jface.viewers.ColumnLabelProvider;
import org.eclipse.jface.viewers.EditingSupport;
import org.eclipse.jface.viewers.IStructuredContentProvider;
import org.eclipse.jface.viewers.TableViewer;
import org.eclipse.jface.viewers.TableViewerColumn;
import org.eclipse.jface.viewers.TextCellEditor;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.window.SameShellProvider;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.MouseAdapter;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import java.lang.all;
import org.eclipse.jface.window.IShellProvider;

/**
 * Explore the new API added in 3.3 and see how easily you can create reusable
 * components
 *
 * @author Tom Schindl <tom.schindl@bestsolution.at>
 * @since 3.2
 */
public class Snippet019TableViewerAddRemoveColumnsWithEditingNewAPI {

    public class Person {
        public String givenname;

        public String surname;

        public String email;

        public this(String givenname, String surname, String email) {
            this.givenname = givenname;
            this.surname = surname;
            this.email = email;
        }
    }

    private class MyContentProvider : IStructuredContentProvider {

        public Object[] getElements(Object inputElement) {
            return arrayFromObject!(Person)( inputElement );
        }

        public void dispose() {
        }

        public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {

        }

    }



    private class GivenNameLabelProvider : ColumnLabelProvider {
        public String getText(Object element) {
            return (cast(Person) element).givenname;
        }
    }

    private class GivenNameEditing : EditingSupport {
        private TextCellEditor cellEditor;

        public this(TableViewer viewer) {
            super(viewer);
            cellEditor = new TextCellEditor(viewer.getTable());
        }

        protected bool canEdit(Object element) {
            return true;
        }

        protected CellEditor getCellEditor(Object element) {
            return cellEditor;
        }

        protected Object getValue(Object element) {
            return stringcast((cast(Person) element).givenname);
        }

        protected void setValue(Object element, Object value) {
            (cast(Person) element).givenname = stringcast(value);
            getViewer().update(element, null);
        }
    }

    private class SurNameLabelProvider : ColumnLabelProvider {
        public String getText(Object element) {
            return (cast(Person) element).surname;
        }
    }

    private class SurNameEditing : EditingSupport {
        private TextCellEditor cellEditor;

        public this( TableViewer viewer ) {
            super(viewer);
            cellEditor = new TextCellEditor(viewer.getTable());
        }

        protected bool canEdit(Object element) {
            return true;
        }

        protected CellEditor getCellEditor(Object element) {
            return cellEditor;
        }

        protected Object getValue(Object element) {
            return stringcast((cast(Person) element).surname);
        }

        protected void setValue(Object element, Object value) {
            (cast(Person) element).surname = stringcast(value);
            getViewer().update(element, null);
        }
    }

    private class EmailLabelProvider : ColumnLabelProvider {
        public String getText(Object element) {
            return (cast(Person) element).email;
        }
    }

    private class EmailEditing : EditingSupport {
        private TextCellEditor cellEditor;

        public this( TableViewer viewer ) {
            super(viewer);
            cellEditor = new TextCellEditor(viewer.getTable());
        }

        protected bool canEdit(Object element) {
            return true;
        }

        protected CellEditor getCellEditor(Object element) {
            return cellEditor;
        }

        protected Object getValue(Object element) {
            return stringcast((cast(Person) element).email);
        }

        protected void setValue(Object element, Object value) {
            (cast(Person) element).email = stringcast(value);
            getViewer().update(element, null);
        }
    }

    private int activeColumn = -1;

    private TableViewerColumn column;
    TableViewer v;
    public this(Shell shell) {
        v = new TableViewer(shell, SWT.BORDER
                | SWT.FULL_SELECTION);

        TableViewerColumn column = new TableViewerColumn(v,SWT.NONE);
        column.setLabelProvider(new GivenNameLabelProvider());
        column.setEditingSupport(new GivenNameEditing(v));

        column.getColumn().setWidth(200);
        column.getColumn().setText("Givenname");
        column.getColumn().setMoveable(true);

        column = new TableViewerColumn(v,SWT.NONE);
        column.setLabelProvider(new SurNameLabelProvider());
        column.setEditingSupport(new SurNameEditing(v));
        column.getColumn().setWidth(200);
        column.getColumn().setText("Surname");
        column.getColumn().setMoveable(true);

        Person[] model = createModel();

        v.setContentProvider(new MyContentProvider());
        v.setInput(new ArrayWrapperObject(model));
        v.getTable().setLinesVisible(true);
        v.getTable().setHeaderVisible(true);

        addMenu();
        triggerColumnSelectedColumn();
    }

    private void triggerColumnSelectedColumn() {
        v.getTable().addMouseListener(new class() MouseAdapter {

            public void mouseDown(MouseEvent e) {
                int x = 0;
                for (int i = 0; i < v.getTable().getColumnCount(); i++) {
                    x += v.getTable().getColumn(i).getWidth();
                    if (e.x <= x) {
                        activeColumn = i;
                        break;
                    }
                }
            }

        });
    }

    private void removeEmailColumn() {
        column.getColumn().dispose();
        v.refresh();
    }

    private void addEmailColumn(int columnIndex) {
        column = new TableViewerColumn(v, SWT.NONE, columnIndex);
        column.setLabelProvider(new EmailLabelProvider());
        column.setEditingSupport(new EmailEditing(v));
        column.getColumn().setText("E-Mail");
        column.getColumn().setResizable(false);

        v.refresh();

        column.getColumn().setWidth(200);

    }

    private Action insertEmailBefore;
    private Action insertEmailAfter;
    private Action removeEmail;
    private Action configureColumns;

    private void addMenu() {
        MenuManager mgr = new MenuManager();

        insertEmailBefore = new class("Insert E-Mail before") Action {
            this(String name){ super(name); }
            public void run() {
                addEmailColumn(activeColumn);
            }
        };

        insertEmailAfter = new class("Insert E-Mail after") Action {
            this(String name){ super(name); }
            public void run() {
                addEmailColumn(activeColumn + 1);
            }
        };

        removeEmail = new class("Remove E-Mail") Action {
            this(String name){ super(name); }
            public void run() {
                removeEmailColumn();
            }
        };

        configureColumns = new class("Configure Columns...") Action {
            this(String name){ super(name); }
            public void run() {
                // Note: the following is not API!
                (new ConfigureColumnsDialog(cast(IShellProvider)new SameShellProvider(v.getControl()), v.getTable())).open();
            }
        };

        mgr.setRemoveAllWhenShown(true);
        mgr.addMenuListener(new class() IMenuListener {

            public void menuAboutToShow(IMenuManager manager) {
                if (v.getTable().getColumnCount() == 2) {
                    manager.add(insertEmailBefore);
                    manager.add(insertEmailAfter);
                } else {
                    manager.add(removeEmail);
                }
                manager.add(configureColumns);
            }

        });

        v.getControl().setMenu(mgr.createContextMenu(v.getControl()));
    }

    private Person[] createModel() {
        Person[] persons = new Person[3];
        persons[0] = new Person("Tom", "Schindl", "tom.schindl@bestsolution.at");
        persons[1] = new Person("Boris", "Bokowski",
                "boris_bokowski@ca.ibm.com");
        persons[2] = new Person("Tod", "Creasey", "tod_creasey@ca.ibm.com");

        return persons;
    }

    /**
     * @param args
     */
    public static void main(String[] args) {
        Display display = new Display();

        Shell shell = new Shell(display);
        shell.setLayout(new FillLayout());
        new Snippet019TableViewerAddRemoveColumnsWithEditingNewAPI(shell);
        shell.open();

        while (!shell.isDisposed()) {
            if (!display.readAndDispatch())
                display.sleep();
        }

        display.dispose();

    }

}

void main(){
    Snippet019TableViewerAddRemoveColumnsWithEditingNewAPI.main(null);
}


