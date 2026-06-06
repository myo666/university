import java.awt.*;
import java.awt.font.FontRenderContext;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.File;
import javax.imageio.ImageIO;

public class GenerateCovers {
    static final String[][] BOOKS = {
        {"活着",       "余华",             "#8B0000"},
        {"三体",       "刘慈欣",           "#1a1a2e"},
        {"人类简史",   "尤瓦尔·赫拉利",    "#2d5016"},
        {"论语",       "孔子",             "#6b3a1f"},
        {"经济学原理", "曼昆",             "#1a3a5c"},
        {"百年孤独",   "加西亚·马尔克斯",  "#4a0e2e"},
        {"围城",       "钱锺书",           "#3e2723"},
        {"时间简史",   "史蒂芬·霍金",      "#0d2137"},
        {"红楼梦",     "曹雪芹",           "#6b1d1d"},
        {"思考，快与慢","丹尼尔·卡尼曼",   "#2c3e50"},
        {"万历十五年", "黄仁宇",           "#5d4037"},
        {"原则",       "瑞·达利欧",        "#1b3a4b"},
    };
    static final int W = 300, H = 420;

    public static void main(String[] args) throws Exception {
        String outDir = args.length > 0 ? args[0] : "src/main/webapp/images";
        new File(outDir).mkdirs();
        for (int i = 0; i < BOOKS.length; i++) {
            String title = BOOKS[i][0], author = BOOKS[i][1];
            Color base = Color.decode(BOOKS[i][2]);
            BufferedImage img = new BufferedImage(W, H, BufferedImage.TYPE_INT_RGB);
            Graphics2D g = img.createGraphics();
            g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_LCD_HRGB);
            g.setPaint(new GradientPaint(0, 0, darken(base,0.4f), W, H, lighten(base,0.15f)));
            g.fillRect(0,0,W,H);
            g.setColor(new Color(255,255,255,12));
            for (int y=0; y<H; y+=8) g.drawLine(0,y,W,y);
            g.setColor(new Color(255,255,255,25)); g.fillRect(0,0,W,6);
            Font tf = fitFont(g,title,W-40);
            g.setFont(tf); g.setColor(new Color(255,255,255,245));
            FontMetrics fm = g.getFontMetrics();
            g.drawString(title, W/2 - fm.stringWidth(title)/2, 180);
            g.setFont(new Font("Microsoft YaHei",Font.PLAIN,18));
            g.setColor(new Color(255,255,255,180));
            fm = g.getFontMetrics();
            g.drawString(author, W/2 - fm.stringWidth(author)/2, 230);
            g.setColor(new Color(255,255,255,60)); g.drawLine(60,260,W-60,260);
            g.setFont(new Font("Microsoft YaHei",Font.PLAIN,11));
            g.setColor(new Color(255,255,255,100));
            fm = g.getFontMetrics();
            g.drawString("知 阅 书 城", W/2 - fm.stringWidth("知 阅 书 城")/2, H-36);
            g.dispose();
            String fn = "cover_" + (i+1) + ".png";
            ImageIO.write(img,"png",new File(outDir,fn));
            System.out.println("Generated: "+fn);
        }
        System.out.println("Done: "+new File(outDir).getAbsolutePath());
    }
    static Font fitFont(Graphics2D g,String t,int mw){FontRenderContext frc=g.getFontRenderContext();for(int s=56;s>=18;s-=2){Font f=new Font("Microsoft YaHei",Font.BOLD,s);if(f.getStringBounds(t,frc).getWidth()<=mw)return f;}return new Font("Microsoft YaHei",Font.BOLD,18);}
    static Color darken(Color c,float f){return new Color(Math.max(0,(int)(c.getRed()*(1-f))),Math.max(0,(int)(c.getGreen()*(1-f))),Math.max(0,(int)(c.getBlue()*(1-f))));}
    static Color lighten(Color c,float f){return new Color(Math.min(255,(int)(c.getRed()+(255-c.getRed())*f)),Math.min(255,(int)(c.getGreen()+(255-c.getGreen())*f)),Math.min(255,(int)(c.getBlue()+(255-c.getBlue())*f)));}
}
