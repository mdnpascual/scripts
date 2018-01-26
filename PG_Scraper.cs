using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace Padguide_Scrape
{
    class Program
    {
        static int index = 0;
        static void Main(string[] args)
        {
            String path = Environment.CurrentDirectory;
            List<List<String>> MonsID = CSV_Parser(path + "\\TBL_MONSTER.csv");
            int i = 0;
            String test = "[";
            //Remove commas and quotes, sort by MONSTER_NO_US
            while (i < MonsID.Count)
            {
                test += "{\"element2\":null,\"awoken_skills\":[],\"rcv_scale\":" +
                MonsID[i][24] + ",\"id\":" +
                MonsID[i][31] + ",\"type3\":null,\"type2\":null,\"image40_href\":\"images/icons/icon_" +
                imgID(MonsID[i][0]) + ".png\",\"xp_curve\":0,\"leader_skill\":\"nan\",\"image40_size\":0,\"version\":0,\"atk_min\":" +
                MonsID[i][18] + ",\"atk_max\":" +
                MonsID[i][19] + ",\"jp_only\":false,\"image60_size\":0,\"max_level\":" +
                MonsID[i][14] + ",\"image60_href\":\"images/icons/icon_" +
                imgID(MonsID[i][0]) + ".png\",\"monster_points\":1,\"rcv_min\":" +
                MonsID[i][20] + ",\"rcv_max\":" +
                MonsID[i][21] + ",\"hp_max\":" +
                MonsID[i][17] + ",\"hp_scale\":" +
                MonsID[i][22] + ",\"name\":\"" +
                MonsID[i][6] + "\",\"team_cost\":" +
                MonsID[i][13] + ",\"type\":1,\"hp_min\":" +
                MonsID[i][16] + ",\"name_jp\":\"nan\",\"rarity\":" +
                MonsID[i][12] + ",\"active_skill\":\"" +
                MonsID[i][10] + "\",\"feed_xp\":0,\"element\":0,\"atk_scale\":" +
                MonsID[i][23] + "},";
                i++;
            }
            test = test.Remove(test.Length - 1);
            test += "]";
            File.WriteAllText(path + "\\monsters.json", test);

            //Remove SEARCH_DATA
            i = 0;
            test = "[";
            List<List<String>> SkillID = CSV_Parser(path + "\\TBL_SKILL.csv");
            while (i < SkillID.Count)
            {
                test += "{\"min_cooldown\":" +
                SkillID[i][9] + ",\"effect\":\"nan\",\"max_cooldown\":" +
                SkillID[i][10] + ",\"name\":\"" +
                SkillID[i][0] + "\"},";
                i++;
            }
            test = test.Remove(test.Length - 1);
            test += "]";
            File.WriteAllText(path + "\\active_skills.json", test);
            
            i = 0;
            List<List<String>> Evo = CSV_Parser(path + "\\TBL_EVOLUTION.csv");
            List<List<String>> EvoMat = CSV_Parser(path + "\\TBL_EVO_MATERIAL.csv");
            List<List<String>> parser = new List<List<String>>();
            while (i < Evo.Count)
            {
                if (!existAlready(parser, Evo[i][1]))
                {
                    parser.Add(new List<String>());
                    parser[parser.Count-1].Add(Evo[i][1]);
                    parser[parser.Count - 1].Add(getMats(EvoMat, Evo[i][0]) + "," + Evo[i][2]);
                }
                else
                {
                    parser[index].Add(getMats(EvoMat, Evo[i][0]) + "," + Evo[i][2]);
                }
                i++;
            }

			//Sort by MonsID
            List<List<String>> SortedList = parser.OrderBy(o => Int32.Parse(o[0])).ToList();
            string[] stringSeparators = new string[] { "]]," };
            i = 0;
            test = "{";
            while (i < SortedList.Count)
            {
                test += "\"" + SortedList[i][0] + "\":[";
                int j = 0;
                while (j < SortedList[i].Count - 1)
                {
                    string[] splitmat = SortedList[i][j + 1].Split(stringSeparators, StringSplitOptions.None);
                    
                    test += "{\"is_ultimate\":true,\"materials\":" + splitmat[0] + "]]," +
                    "\"evolves_to\":" + splitmat[1] + "},";
                    j++;
                }
                test = test.Remove(test.Length - 1);
                test += "],";
                i++;
            }
            test = test.Remove(test.Length - 1);
            test += "}";
            File.WriteAllText(path + "\\evolutions.json", test);
        }

        private static string getMats(List<List<String>> EvoMat, string tv_seq)
        {
            string output = "[";
            int i = 0;

            while (i < EvoMat.Count)
            {
                if (EvoMat[i][2] == tv_seq)
                {
                    output += "[" + EvoMat[i][1] + ",1],";
                }
                i++;
            }
            output = output.Remove(output.Length - 1);
            output += "]";
            return output;
        }

        private static bool existAlready(List<List<String>> parser, string target)
        {
            int i = 0;
            while (i < parser.Count)
            {
                try
                {
                    if (parser[i][0] == target)
                    {
                        index = i;
                        return true;
                    }
                }
                catch (Exception e)
                {
                    return false;
                }  
                i++;
            }
            return false;
        }

        private static string imgID(string orig)
        {
            if (orig.Length == 4)
                return orig;
            else if (orig.Length == 3)
                return "0" + orig;
            else if (orig.Length == 2)
                return "00" + orig;
            else if (orig.Length == 1)
                return "000" + orig;
            else
                return "ERROR";
        }

        private static List<List<String>> CSV_Parser(String filename)
        {
            StreamReader reader = new StreamReader(File.OpenRead(filename), System.Text.Encoding.Default, true);
            String line = reader.ReadLine();   //Waste reading 1 line
            int i = 0;

            List<List<String>> csv = new List<List<String>>();
            while (!reader.EndOfStream)
            {
                line = reader.ReadLine();
                String[] values = line.Split(',');  //Delimiter
                csv.Add(new List<String>());

                int j = 0;
                while (j < values.Length)
                {
                    csv[i].Add(values[j]);
                    j++;
                }
                i++;
            }
            return csv;
        }
    }
}
